module API
  class V5
    class Videos < Grape::API
      include Grape::Kaminari

      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers do
        include EventLogHelper
        include LearningProgressesHelpers
        include VideosHelpers
        include LearningProgressHelper
        params :id do
          requires :id, type: Integer, allow_blank: false, description: 'Video ID'
        end
      end

      resource :videos do
        desc 'Video Bookmark API', headers: API::Root::HEADERS
        params { use :id }
        post ':id/bookmarks' do
          video = Video.find(params[:id])
          Star.find_or_create_by(student: @current_student, video: video)
          if video.duplicated
            video.duplicated_videos.each { |dup| Star.find_or_create_by(video: dup, student: @current_student) }
          end
          logger(Settings.event_name.star_video, event_data: video_event_log_data(video))
        end

        desc 'Video Unbookmark API', headers: API::Root::HEADERS
        params { use :id }
        delete ':id/bookmarks' do
          video = Video.find(params[:id])
          Star.find_by!(student: @current_student, video: video).destroy
          if video.duplicated
            video.duplicated_videos.each { |dup| Star.find_by!(video: dup, student: @current_student).destroy }
          end
          logger(Settings.event_name.unstar_video, event_data: video_event_log_data(video))
        end

        desc 'Video Watched API', headers: API::Root::HEADERS
        params do
          use :id
          requires :viewed_time, type: Integer, allow_blank: false, description: 'ViewedTime'
        end
        post ':id/watches', rabl: 'v5/videos/watches' do
          video             = Video.find(params[:id])
          pre_level         = @current_student.level
          video_viewing     = VideoViewing.create!(video: video, student: @current_student, viewed_time: params[:viewed_time])
          @video_watched    = video_viewing.video
          @experience_point = video_viewing.experience_point
          logger(Settings.event_name.watching_video,
                 event_data: video_watched_log_data(video, params[:viewed_time]))
          @current_level    = @current_student.reload.level
          @level_up_flag    = level_up(pre_level, @current_level)
          @unit_trophy_flag = video_viewing.unit_trophy_flag
          @schoolbook_trophy_flag = video_viewing.schoolbook_trophy_flag
          schoolbook         = video_viewing.schoolbook
          watched_videos_id  = video_viewing.video_ids_current_watched
          @unit_name         = video_viewing.unit_title
          @trophies_progress = find_trophies_progress(video_viewing, schoolbook, watched_videos_id)
        end

        paginate per_page: 20, max_per_page: 20, offset: false
        desc 'Video Watched History List API', headers: API::Root::HEADERS
        get '/histories', rabl: 'v5/videos/histories' do
          Video.current_student_id = @current_student.id
          @videos_list =
            @current_student.video_viewings
                            .order(created_at: :desc)
                            .includes(video: %i(subject stars_with_current_student))
                            .group_by { |histories| histories[:video_id] }
                            .map { |video_id, histories| [histories.first, histories.count(&:watched)] }.to_h

          @watching_history = Kaminari.paginate_array(@videos_list.keys)
                                      .page(params[:page])
                                      .per(params[:per_page])
        end

        desc 'Video Bookmarked List API', headers: API::Root::HEADERS
        params do
          optional :max_id, type: Integer
          optional :per_page, type: Integer, default: 20
        end
        get '/bookmarks', rabl: 'v5/videos/bookmarks' do
          Video.current_student_id = @current_student.id
          bookmark_created_at = @current_student.stars.find_by(video_id: params[:max_id])&.created_at
          @bookmarks = @current_student.stars.find_old_stars(bookmark_created_at)
                                       .order(created_at: :DESC)
                                       .limit(params[:per_page])
                                       .includes(video: %i(subject
                                                           video_viewings_with_current_student))
        end

        paginate per_page: 20, max_per_page: 20, offset: false
        desc 'Search Video', headers: API::Root::HEADERS
        params do
          requires :keyword, type: String, allow_blank: false, description: 'Keywords input'
          optional :grade, type: String, values: %w(c k), allow_blank: true, description: 'Grade'
        end
        get '/search', rabl: 'v5/videos/search'  do
          Video.current_student_id = @current_student.id
          keyword = searched_keyword(params[:keyword])
          @videos = searched_videos(keyword).by_schoolyear(params[:grade]).includes_videos
          @units = @videos.map do |video|
            schoolbook = find_schoolbook_with_video(video)
            next unless schoolbook
            belonging_unit(schoolbook, video)
          end
          @units              = @units.compact.uniq
          @videos_watched_ids = @current_student.watched_videos.pluck(:id)
          @units_count        = @units.size
          @videos_count       = @videos.size
          @videos = Kaminari.paginate_array(@videos.to_a)
                            .page(params[:page])
                            .per(params[:per_page])
        end

        desc 'show video detail', headers: API::Root::HEADERS
        params { use :id }
        get ':id', rabl: 'v5/videos/show' do
          @video = Video.find(params[:id])
          Video.current_student_id = @current_student.id
          @video_url = Millvi.get_video_url(@video.id_contents, request.user_agent, @player_type)
          @double_speed_video_url = Millvi.get_video_url(@video.double_speed_video_id_contents, request.user_agent, @player_type)
          @subject = @video.subject
          schoolyear = @video.schoolyear == 'c' ? 'c1' : @video.schoolyear
          schoolbook = Schoolbook.find_by!(id: @current_student.get_schoolbook_id(schoolyear, @video.subject.name_and_type))
          @belong_schoolbook = schoolbook.has_video?(@video.id) ? schoolbook : Schoolbook.where(subject: @subject).find { |sb| sb.video_ids.include?(@video.id) }
          @previous_videos = @video.previous_videos_schoolbook(@belong_schoolbook) if @belong_schoolbook
          @next_videos = @video.next_videos_schoolbook(@belong_schoolbook) if @belong_schoolbook

          @current_student_watched_count = @video.video_viewings_with_current_student.size
          @is_bookmarked = @video.stars_with_current_student.present?
        end

        desc 'Videos For Subject API', headers: API::Root::HEADERS
        params do
          requires :year,    type: String, values: %w(c1 c2 c3 k), description: 'School year'
          requires :subject, type: String, values: Settings.subject_name_and_type.c + Settings.subject_name_and_type.k,
                             combination_of_year_and_subject: true, description: 'Subject and type'
        end
        get ':year/:subject' , rabl: 'v5/videos/index' do
          Video.current_student_id = @current_student.id
          @schoolbook = Schoolbook.find_by!(id: @current_student.get_schoolbook_id(params[:year], params[:subject]))
          @units      = add_videos_for_each_unit(@schoolbook.units, @schoolbook.videos)

          @trophies_progress  = trophies_progress(@units)
          @videos_progress = videos_progress(@units)
          @videos_suggest  = find_videos_suggest(@units, @videos_progress)
        end

        desc 'Log play start the video', headers: API::Root::HEADERS
        params do
          use :id
          requires :position, type: Integer, description: 'Position of video'
        end
        post ':id/plays' do
          video = Video.find_by(id: params[:id])
          position_param = params[:position].to_i <= video.duration ? params[:position].to_i : video.duration
          if position_param >= 0
            logger(Settings.event_name.play_video,
                   event_data: video_event_log_data(video, position_param))
          else
            error('InvalidPositionParams', 'Position params is smaller than 0',
                  400, true, 'error')
          end
        end
      end
    end
  end
end
