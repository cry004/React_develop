module API
  class V5
    class Students < Grape::API
      helpers do
        include LearningProgressesHelpers
      end

      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :students do
        desc 'Student Detail API', headers: API::Root::HEADERS
        get 'me', rabl: 'v5/students/show' do
        end

        desc 'Update avatar and nickname of Student API', headers: API::Root::HEADERS
        params do
          requires :avatar,    type: Integer, allow_blank: false, description: 'Avatar'
          requires :nick_name, type: String, allow_blank: false, description: 'NickName'
        end
        put '/me' do
          student = ActiveType.cast(@current_student, Student::ProfileUpdator)
          student.update!(avatar: params[:avatar], nick_name: params[:nick_name])
        end

        desc 'Student Schoolbooks API', headers: API::Root::HEADERS
        get '/me/schoolbooks', rabl: 'v5/schoolbooks/index' do
          grouped_schoolbooks = Schoolbook.configurables.order(:year, :sort).group_by(&:year)
          @schoolbooks = grouped_schoolbooks.map do |year, schoolbooks|
            { schoolyear: year, subject: schoolbooks.group_by(&:subject) }
          end
          @setted_schoolbooks = @current_student.schoolbooks['info']
        end

        desc 'Once this API called, dialog box which guide to configure schoolbooks does not appear.', headers: API::Root::HEADERS
        put 'me/schoolbook_dialogs' do
          @current_student.update(dialog_enabled: false)
        end

        desc 'Update Schoolbooks API', headers: API::Root::HEADERS
        params do
          requires :schoolbooks, schoolbooks_json_validation: true, description: <<-NOTE
            ----schoolbooks configuration----
            Format:
              {
                "c1": {
                  "english": {
                    "name": "標準"
                  },
                  "mathematics": {
                    "name": "未来へひろがる数学（啓林館）"
                  },
                  "subject": {
                    "name": "display_name"
                  },
                  ...
                }
              }
          NOTE
        end
        put 'me/schoolbooks', rabl: 'v5/default' do
          begin
            Rails.logger.info(params[:schoolbooks]) if Rails.env.api_develop?
            @current_student.update(dialog_enabled: false) if @current_student.dialog_enabled
            @current_student.update_schoolbooks(params[:schoolbooks])

            watched_videos            = @current_student.videos.watched_videos
            trophies_completed        = find_trophies_completed(@current_student, watched_videos)
            @current_student.reload.trophies_count
            @current_student.update(trophies_count: trophies_completed)
          rescue
            error 'CanNotUpdateSchoolbooks', 'can not update schoolbooks.', 204, true, 'error'
          end
        end

        desc 'Update school of Student API', headers: API::Root::HEADERS
        params do
          requires :school, type: String, values: %w(c k), description: 'c: junior high school<br>k: high school'
        end
        put 'me/schools' do
          @current_student.update!(school: params[:school])
          logger(Settings.event_name.change_school)
        end

        desc 'Student PrivacySetting API', headers: API::Root::HEADERS
        get '/me/privacy_settings', rabl: 'v5/students/privacy_settings' do
        end

        desc 'change privacy settings', headers: API::Root::HEADERS
        params do
          requires :private_flag, type: Boolean, allow_blank: false, description: 'private flag'
        end
        put '/me/privacy_settings' do
          @current_student.update(private_flag: params[:private_flag])
        end
      end
    end
  end
end
