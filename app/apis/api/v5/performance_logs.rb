module API
  class V5
    class PerformanceLogs < Grape::API
      before do
        authenticate!
        request_variant # may not be necessary
      end

      resource :performance_logs do
        desc 'Performance measurement API', headers: API::Root::HEADERS
        params do
          requires :results, type: Array do
            requires :process_name, type: String
            requires :duration,     type: Integer
          end
        end
        post do
          results = params[:results].map do |result|
            { result[:process_name] => result[:duration] }
          end

          logger(Settings.event_name.performance_logs,
                 event_data: { durations: results })
        end
      end
    end
  end
end
