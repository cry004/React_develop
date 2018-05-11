module API
  class V5
    class Devices < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers do
        params :token do
          requires :token, type: String, allow_blank: false, description: 'DeviceToken'
        end
      end

      resource :devices do
        desc 'DeviceToken Register API', headers: API::Root::HEADERS
        params { use :token }
        post do
          os    = judge_os
          token = params[:token]

          unless os.in?(%w(ios android))
            error('UnkonwnOS', 'os is not known.', 400, true, 'error')
          end

          Device.others(os: os, token: token, student: @current_student)
                .destroy_all

          # records are being made, so leave one and remove others
          devices = @current_student.devices.order(:created_at)
          Device.where(id: devices[0..-2].map(&:id)).destroy_all if 1 < devices.size

          if (device = devices.last)
            device.update!(token: token, os: os)
          else
            Device.create!(token: token, pushable: @current_student, os: os)
          end
        end

        desc 'DeviceToken Delete API', headers: API::Root::HEADERS
        params { use :token }
        delete do
          device = Device.owns(student: @current_student,
                               token:   params[:token],
                               os:      judge_os).take!
          device.destroy
        end
      end
    end
  end
end
