module API
  class V5
    class Questions < Grape::API
      include Grape::Kaminari

      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers do
        include QuestionsHelpers
        params :id do
          requires :id, type: Integer, allow_blank: false, description: 'Question ID'
        end
      end

      resource :questions do
        paginate per_page: 20, max_per_page: 20, offset: false
        desc 'Questions List API', headers: API::Root::HEADERS
        get rabl: 'v5/questions/index' do
          questions_list       = @current_student.questions.includes(:subject, :video).order(created_at: :DESC).displayables
          @question_pagination = paginate(questions_list).page(params[:page])
                                                         .per(params[:per_page])
          logger(Settings.event_name.browse_try_it, event_data: params_for_log(params))
        end

        desc 'Get availability question checking', headers: API::Root::HEADERS
        get '/createability', rabl: 'v5/default' do
          message_about('notification_holidays') if company_holiday?
        end

        desc 'Question Detail API', headers: API::Root::HEADERS
        params { use :id }
        get ':id', rabl: 'v5/questions/show' do
          @question = @current_student.questions.displayables.find(params[:id])
        end

        desc 'Question Create API', headers: API::Root::HEADERS
        params do
          optional :video_id, type: Integer, allow_blank: false, description: 'Video ID'
          given :video_id do
            requires :position, type: Integer, allow_blank: false, description: 'Position of the Video when Creating the Question'
          end
        end
        post rabl: 'v5/questions/create' do
          video = Video.find_by(id: params[:video_id])
          @thumbnail_url = video&.incomprehensible_thumbnail_url(params[:position])
          @question_id   = Question.create_tryit(video, @current_student, @thumbnail_url, params[:position])
          @question_date = Question.unscoped.find_by(id: @question_id).created_at.to_s(:published_on_with_dow)
          logger(Settings.event_name.create_try_it, event_data: video_event_log_data(video, params[:position]))
        end

        desc 'Question Draft API', headers: API::Root::HEADERS
        params { use :id }
        get '/:id/drafts', rabl: 'v5/questions/drafts' do
          @question        = @current_student.questions.drafts.find(params[:id])
          @first_post_body = @question.first_post_body
          @photo           = @question.posts.student_post.first&.photo
        end

        desc 'Question Delete API', headers: API::Root::HEADERS
        params { use :id }
        delete ':id' do
          question = @current_student.questions.except_deleted_state_scope.find(params[:id])
          question.delete_tryit
        end

        desc 'Question Resolve API', headers: API::Root::HEADERS
        params { use :id }
        put ':id/resolves' do
          if (question = @current_student.questions.displayables.find_by(id: params[:id])) && question.can_close?
            question.close
            logger(Settings.event_name.resolve_question, event_data: question_event_log_data(question))
          else
            error 'CanNotResolveQuestion', "question can't resolve", 204, true, 'error'
          end
        end

        desc 'Question Unresolve API', headers: API::Root::HEADERS
        params { use :id }
        put ':id/unresolves' do
          if (question = @current_student.questions.displayables.find_by(id: params[:id])) && question.can_unresolve?
            question.unresolve
            logger(Settings.event_name.unresolve_question, event_data: question_event_log_data(question))
          else
            error 'CanNotChangeQuestionState', "question can't be changed to answered from resolved", 204, true, 'error'
          end
        end

        desc 'Question Read API', headers: API::Root::HEADERS
        params { use :id }
        put ':id/reads' do
          question = @current_student.questions.displayables.find_by(id: params[:id])
          if (unread_posts = question&.posts&.unreads).present?
            unread_posts.each(&:read)
            logger(Settings.event_name.read_answer, event_data: question_event_log_data(question))
          else
            error 'CanNotReadQuestion', "question can't be read", 204, true, 'error'
          end
        end

        desc 'Put Question API', headers: API::Root::HEADERS
        params do
          requires :id,          type: Integer, description: "Question's id"
          requires :create_flag, type: Boolean, upload_file_for_without_video_validation: true, description: "If flag true questions state is 'open' else 'draft'"

          given create_flag: ->(val) { val == true } do
            optional :with_video,  type: Hash do
              requires :body, type: String, description: 'Contents'
            end
            optional :without_video, type: Hash do
              optional :upload_file, type: Rack::Multipart::UploadedFile
              requires :body,        type: String, description: 'Contents'
              requires :course_name, type: String, description: 'Course name',
                                     values: I18n.t('courses_name').keys.map(&:to_s)
            end
            at_least_one_of :with_video, :without_video
          end

          given create_flag: ->(val) { val == false } do
            optional :with_video,  type: Hash do
              optional :body, type: String, description: 'Contents'
            end
            optional :without_video, type: Hash do
              optional :upload_file, type: Rack::Multipart::UploadedFile
              optional :body,        type: String, description: 'Contents'
              optional :course_name, type: String, description: 'Course name',
                                     values: I18n.t('courses_name').keys.map(&:to_s)
            end
          end
        end
        put '/:id', rabl: 'v5/questions/show.rabl' do
          begin
            question = @current_student.questions.except_deleted_state_scope.find(params[:id])

            unless question.can_be_open?
              error 'CanNotUpdateQuestion', 'Question is already opened', 204, true, 'error'
            end

            message_about('apology_message') if company_holiday? && params[:create_flag]

            if question.video_id
              body = params[:with_video] ? params[:with_video][:body] : ''
              @question = question.update_with_video(body, params[:create_flag])
            else
              param = params[:without_video]
              if param
                upload_file = param[:upload_file]
                subject     = param[:course_name]
                body        = param[:body]
              end
              old_question_flag = false
              @question = question.update_without_video(upload_file, subject, body,
                                                        params[:create_flag], old_question_flag)
            end

            @current_student.recount_unreads

            logger(Settings.event_name.send_question, event_data: question_event_log_data(question)) if params[:create_flag]
          rescue Exceptions::CurrentPointShortageError
            error 'CurrentPointShortageError', 'Current point is shortage', 404, true, 'error'
          end
        end
      end
    end
  end
end
