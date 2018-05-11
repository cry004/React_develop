module API
  class V5
    class Logout < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :logout do
        desc 'Logout API', headers: API::Root::HEADERS
        delete do
          @current_student.update(access_token: nil)
        end
      end
    end
  end
end
