module API
  class V5
    class LearningProgresses < Grape::API
      helpers do
        include LearningProgressesHelpers
      end

      before do
        authenticate!
        request_variant
      end

      resource :learning_progresses do
        desc 'Student learning progresses', headers: API::Root::HEADERS
        get '/', rabl: 'v5/learning_progresses/index' do
          @school                    = @current_student.school
          @subject_list              = current_student_subject(@current_student, @school)
          @watched_videos            = @current_student.videos.watched_videos
          @trophies_completed        = find_trophies_completed(@current_student, @watched_videos)
          video_ids_in_any_book      = filter_video_ids(Schoolbook.all).flatten.uniq
          videos_watched             = @current_student.videos
                                         .where(video_viewings: { watched: true })
                                         .order('video_viewings.created_at DESC').to_a.uniq
          @last_five_subject_watched = remove_videos_free(videos_watched, video_ids_in_any_book)
                                         .group_by { |video| [video[:schoolyear], video[:subject_id]] }
                                         .map { |key, videos| { [key.first, key.last] => videos } }.take(5)
        end
      end
    end
  end
end
