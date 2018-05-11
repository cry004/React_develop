module API
  class V5 < Grape::API
    format         :json
    default_format :json

    formatter :json, Grape::Formatter::Rabl

    prefix :api

    version 'v5', using: :path

    # Catch validation errors of parameters
    rescue_from Grape::Exceptions::ValidationErrors do |err|
      extend API::Root.helpers

      endpoint = env['api.endpoint']

      type = 'ParameterValidationErrors'
      data = { error_type:    type,
               error_message: err.message }
      user = endpoint.instance_variable_get(:@current_student)

      logger(type, event_data: data, user: user, req: endpoint.request)

      code   = 400
      status = Oj.dump(meta: { error_type:     type,
                               code:           code,
                               error_messages: [err.message] })

      res = Rack::Response.new(status, code)
      res.delete_cookie 'subject',    { value: endpoint.params['subject'], path: '/' }
      res.delete_cookie 'schoolyear', { value: endpoint.params['year'],    path: '/' }
      res.finish
    end

    rescue_from ActiveRecord::RecordInvalid do |err|
      extend API::Root.helpers

      endpoint = env['api.endpoint']

      type  = err.class
      param = endpoint.params.delete_if { |key, _value| key.in?(%w(password)) }
      data  = { error_type:    type,
                error_message: err.message,
                params:        param,
                request_uri:   env['REQUEST_URI'] }
      user  = endpoint.instance_variable_get(:@current_student)
      req   = endpoint.request
      level = 'fatal'

      logger(type, event_data: data, user: user, req: req, logger_level: level)

      code    = 400
      message = err.record.errors.full_messages

      error!({ meta: { error_type: type, code: code, error_messages: message } }, code)
    end

    rescue_from ActiveRecord::RecordNotFound do |err|
      extend API::Root.helpers
      endpoint = env['api.endpoint']

      type  = err.class
      param = endpoint.params.delete_if { |key, _value| key.in?(%w(password)) }
      data  = { error_type:    type,
                error_message: err.message,
                params:        param,
                request_uri:   env['REQUEST_URI'] }
      user  = endpoint.instance_variable_get(:@current_student)
      req   = endpoint.request
      level = 'fatal'

      logger(type, event_data: data, user: user, req: req, logger_level: level)

      code    = 404
      message = 'RecordNotFound'

      error!({ meta: { error_type: type, code: code, error_message: message } }, code)
    end

    rescue_from :all do |err|
      extend API::Root.helpers

      endpoint = env['api.endpoint']

      type  = err.class
      param = endpoint.params.delete_if { |key, _value| key.in?(%w(password)) }
      data  = { error_type:    type,
                error_message: err.backtrace[0..30].join('\n'),
                params:        param,
                request_uri:   env['REQUEST_URI'] }
      user  = endpoint.instance_variable_get(:@current_student)
      req   = endpoint.request
      level = 'fatal'

      logger(type, event_data: data, user: user, req: req, logger_level: level)

      code    = 500
      message = I18n.t('errors.messages.unknown')
      status  = Oj.dump(meta: { error_type:     'ServerError',
                                code:           code,
                                error_messages: [message] })
      res = Rack::Response.new(status, code)
      res.delete_cookie 'subject',    { value: endpoint.params['subject'], path: '/' }
      res.delete_cookie 'schoolyear', { value: endpoint.params['year'],    path: '/' }
      res.finish
    end

    helpers do
      def error(type = 'InternalServerError', message = I18n.t('errors.messages.unknown'), code = 500, logger_flag = true, logger_level = 'fatal')
        logger(type, event_data: { error_type: type, error_message: message }, logger_level: logger_level) if logger_flag
        error!({ meta: { error_type: type, code: code, error_messages: Array(message) } }, http_response_code(code))
      end

      def http_response_code(code)
        code == 204 ? 200 : code
      end
    end

    mount API::V5::Courses
    mount API::V5::Devices
    mount API::V5::JukuLearnings
    mount API::V5::LearningProgresses
    mount API::V5::Login
    mount API::V5::Logout
    mount API::V5::News
    mount API::V5::Notifications
    mount API::V5::PerformanceLogs
    mount API::V5::PointRequests
    mount API::V5::Questions
    mount API::V5::Rankings
    mount API::V5::SearchedWords
    mount API::V5::Students
    mount API::V5::TeacherRecommendations
    mount API::V5::Units
    mount API::V5::Versions
    mount API::V5::VideoTags
    mount API::V5::Videos
    mount API::V5::Workbooks

    if Rails.env.in?(%w(development api_develop api_staging))
      add_swagger_documentation info: { title: 'Try IT API' }
    end
  end
end
