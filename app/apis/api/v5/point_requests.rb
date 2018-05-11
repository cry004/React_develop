module API
  class V5
    class PointRequests < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      helpers do
        def event_log_data
          { available_point:       @current_student.available_point,
            current_monthly_point: @current_student.current_monthly_point }
        end
      end

      resource :point_requests do
        desc 'Point Request API', headers: API::Root::HEADERS
        post do
          PointRequestMailer.settings_monthly_points_at_parent(@current_student)
                            .deliver_now

          logger(Settings.event_name.point_request, event_data: event_log_data)
        end
      end
    end
  end
end
