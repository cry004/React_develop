module API
  class V5
    class Login < Grape::API
      resource :login do
        desc 'Login API'
        before do
          request_variant # may not be necessary
        end

        params do
          requires :studentId, type: String, allow_blank: false, description: 'Student ID'
          requires :password,  type: String, allow_blank: false, description: 'Password'
        end
        post rabl: 'v5/students/show' do
          begin
            @current_student = Student.authenticate(params, request)
            if @current_student
              create_access_token
              logger(Settings.event_name.success_login)
            else
              logger(Settings.event_name.fail_login,
                     event_data: { params_student_id: params[:studentId] })
              error('LoginError', I18n.t('errors.messages.login'), 403, false)
            end
          rescue => err
            if err.is_a?(Fist::Unauthorized)
              error(err.class, I18n.t('errors.messages.fist_auth'), 403, true, 'error')
            else
              error(err.class, err.backtrace.join('\n'))
            end
          end
        end
      end
    end
  end
end
