module API
  class V5
    class JukuLearnings < Grape::API
      include Grape::Kaminari

      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers PaginationHelpers

      resource :juku_learnings do
        desc 'Self Learnings List API', headers: API::Root::HEADERS
        get '/currents', rabl: '/v5/juku_learnings/currents' do
          Video.current_student_id = @current_student.id
          @learnings = @current_student.learnings
                                       .include_video_subject
                                       .include_subject
                                       .currents
                                       .curriculum_order
          @archive_existence_flag = @current_student.learnings.archives.exists?
        end

        paginate per_page: 10, max_per_page: 10, offset: false
        desc 'Archived Self Learnings API', headers: API::Root::HEADERS
        get '/archives', rabl: '/v5/juku_learnings/archives' do
          Video.current_student_id = @current_student.id
          learnings = @current_student.learnings
                                      .include_videos
                                      .archives
                                      .newest_first
          @learnings = paginate(learnings).page(params[:page]).per(params[:per_page])
        end
      end
    end
  end
end
