module API
  class V5
    class Notifications < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers NotificationsHelpers

      resource :notifications do
        desc 'Notifications API', headers: API::Root::HEADERS
        get rabl: 'v5/notifications/index' do
          @notifications = search_notifications(student: @current_student)
        end
      end
    end
  end
end
