module JukuAPI
  class Root < Grape::API
    HEADERS = {
      'X-Authorization': {
        default:     'Bearer ',
        description: "Set 'Bearer ' + 'access_token' from API response",
        required:    true
      }
    }.freeze

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      extend JukuAPI::Root.helpers

      type       = 'ParameterValidationErrors'
      message    = e.message
      event_data = { error_type: type, error_message: message }

      endpoint   = env['api.endpoint']
      user       = endpoint.instance_variable_get('@current_chief')

      logger(type, event_data: event_data, user: user, req: endpoint.request)

      code = 404
      meta = { error_type: type, code: code, error_message: message }

      Rack::Response.new(Oj.dump(meta: meta), code).finish
    end

    rescue_from Exceptions::FistStriker::Error do |e|
      extend JukuAPI::Root.helpers

      type         = e.class
      message      = e.message
      endpoint     = env['api.endpoint']
      event_params = endpoint.params.select { |k, _| k != 'password' }
      user         = endpoint.instance_variable_get('@current_chief')
      event_data   = { error_type:    type,
                       error_message: message,
                       params:        event_params,
                       request_uri:   env['REQUEST_URI'] }

      logger(type, event_data:   event_data,
                   user:         user,
                   req:          endpoint.request,
                   logger_level: 'fatal')

      code = type::CODE
      meta = { error_type: type, code: code, error_message: message }

      Rack::Response.new(Oj.dump(meta: meta), code).finish
    end

    rescue_from :all do |e|
      extend JukuAPI::Root.helpers

      type         = e.class
      message      = e.backtrace[0..30].join("\n")
      endpoint     = env['api.endpoint']
      event_params = endpoint.params.select { |k, _| k != 'password' }
      user         = endpoint.instance_variable_get('@current_chief')
      event_data   = { error_type:    type,
                       error_message: message,
                       params:        event_params,
                       request_uri:   env['REQUEST_URI'] }

      logger(type, event_data:   event_data,
                   user:         user,
                   req:          endpoint.request,
                   logger_level: 'fatal')

      code = 500
      meta = { error_type:    'ServerError',
               code:          code,
               error_message: 'unknown error occurred.' }

      Rack::Response.new(Oj.dump(meta: meta), code).finish
    end

    helpers do
      def authenticate!
        auth_header = headers['X-Authorization']

        error('X-AuthorizationHeaderMissing',
              'X-Authorization Header is not provided.',
              401, true, 'error') unless auth_header

        access_token = auth_header.match(/\ABearer\s+(.+)\z/)&.captures&.first

        error('AccessTokenMissing',
              'access_token is not provided.',
              401, true, 'error') unless access_token

        claim = decode_access_token(access_token)

        error('ChiefNotExistException',
              'the chief claimed is not exist.',
              401, true, 'error') unless valid_claim?(claim)

        error('NbfClaimException',
              'nbf claim is invalid.',
              401, true, 'error') unless valid_nbf?(claim)

        error('Unauthorized',
              'the access_token provided is expired. need to sign in.',
              401, true, 'error') unless authorized?(claim)
      end

      def decode_access_token(access_token)
        JSON::JWT.decode(access_token, ACCESS_TOKEN_SIGNATURE)
      rescue => e
        error(e.class, e.message, 401, true, 'info')
      end

      def valid_claim?(claim)
        id = claim['sub']['chief_id']
        @current_chief = Chief.find_by(id: id)
      end

      def valid_claim_shin_cd?(claim)
        @current_chief.shin_cd == claim['sub']['shin_cd']
      end

      def valid_claim_tmp_cd?(claim)
        tmp_cd = get_tmp_cd_from(@current_chief)
        tmp_cd == claim['sub']['tmp_cd']
      end

      # TODO: Add delegate to model: :Chief
      def get_tmp_cd_from(chief)
        classroom_id = chief.classroom_id
        Classroom.find_by(id: classroom_id).tmp_cd
      end

      def valid_nbf?(claim)
        Time.zone.at(claim['nbf']) <= 3.seconds.since
      end

      def authorized?(claim)
        !expired?(claim) && @current_chief.access_token
      end

      def expired?(claim)
        Time.zone.at(claim['exp']) < Time.current
      end

      # NOTE: For :auto_login, and :test_login
      def create_one_time_token
        @one_time_token =
          JSON::JWT.new(iss: 'try-it-juku-test',
                        exp: 5.minutes.since,
                        nbf: Time.current,
                        sub: { shin_cd: @current_chief.shin_cd })
                   .sign(ACCESS_TOKEN_SIGNATURE, :HS256).to_s
      end

      def update_one_time_token
        @current_chief.update(one_time_token: @one_time_token)
      end

      def create_access_token
        @access_token =
          JSON::JWT.new(iss: 'try-it-juku',
                        exp: access_token_expiry,
                        nbf: Time.current, # means "Not Before"
                        sub: { chief_id: @current_chief.id }
                       )
                   .sign(ACCESS_TOKEN_SIGNATURE, :HS256).to_s
      end

      def access_token_expiry
        Settings.access_token.hours_to_expire.default.hours.since
      end

      def update_access_token
        @current_chief.update(access_token: @access_token)
      end

      def error(type = 'InternalServerError', message = 'unknown error occurred.', code = 500, logger_flag = true, logger_level = 'fatal')
        if logger_flag
          event_data = { error_type: type, error_message: message }
          logger(type, event_data: event_data, logger_level: logger_level)
        end

        meta = { error_type: type, code: code, error_message: message }
        code = code == 204 ? 200 : code

        error!({ meta: meta }, code)
      end

      def logger(event_name, event_data: {}, user: @current_chief, logger_level: 'info', req: request)
        locals = { request:    req,
                   user:       user,
                   event_name: event_name,
                   event_data: event_data }

        json = Rabl.render(false, 'event_log',
                           view_path: 'app/views/juku_api',
                           format:    :json,
                           locals:    locals)

        Rails.logger.send(logger_level, json)
      end

      def get_subsubjects(subject)
        get_normal_subjects(subject) + get_high_school_exam_subjects(subject) + get_university_exam_subjects(subject)
      end

      def get_normal_subjects(subject)
        school       = subject.school
        subject_name = subject.name
        if school == 'k' && (subject_name == 'classics' || subject_name == 'chinese_classics')
          [
            { sub_subject_key:        subject_name,
              sub_subject_name:       I18n.t("sub_subject.#{school}.#{subject_name}"),
              sub_subject_color_code: Subject::V3::COLOR_CODE[school][subject_name] }
          ]
        elsif school == 'c' && subject_name.in?(%w(english mathematics science))
          (1..3).map do |year|
            key = "#{school}#{year}_#{subject_name}_regular"
            { sub_subject_key:        key,
              sub_subject_name:       I18n.t("sub_subject.#{school}.#{key}"),
              sub_subject_color_code: Subject::V3::COLOR_CODE[school][subject_name] }
          end
        else
          #Order subjects list in case sociology
          name_and_types = if subject.name == 'sociology'
            subject.children.for_names_with_order(%w(geography history civics))
          else
            subject.children
          end.pluck(:name, :type)

          name_and_types.map do |name, type|
            next if type.in?(Subject::EXAM_LIST)
            { sub_subject_key:        name,
              sub_subject_name:       I18n.t("sub_subject.#{school}.#{name}"),
              sub_subject_color_code: Subject::V3::COLOR_CODE[school][name] }
          end.compact
        end
      end

      def get_high_school_exam_subjects(subject)
        return [] unless (school = subject.school) == 'c'

        names    = subject.subtree.pluck(:name)
        subjects = ::Subject.for_high_school_exam.where(name: names)
        subjects.order(:sort).pluck(:name, :type).map do |name, type|
          { sub_subject_key:        "#{name}_#{type}",
            sub_subject_name:       I18n.t("sub_subject.#{school}.#{name}_#{type}"),
            sub_subject_color_code: ::Subject::V3::COLOR_CODE[school][name] }
        end
      end

      def get_university_exam_subjects(subject)
        return [] unless (school = subject.school) == 'k'

        subjects = case subject.name
                   when 'world_history_b'
                     ::Subject.for_university_exam.where("type LIKE 'world_history%' OR name = 'world_history_b'")
                   when 'japanese_history_b'
                     ::Subject.for_university_exam.where("type LIKE 'japanese_history%' OR name = 'japanese_history_b'")
                   when 'modern_language', 'classics', 'chinese_classics'
                     ::Subject.for_university_exam.where('type LIKE ?', "#{subject.name}%")
                   else
                     names = subject.subtree.pluck(:name)
                     ::Subject.for_university_exam.where(name: names)
                   end

        subjects.order(:sort).pluck(:name, :type).map do |name, type|
          { sub_subject_key:        "#{name}_#{type}",
            sub_subject_name:       I18n.t("sub_subject.#{school}.#{name}_#{type}"),
            sub_subject_color_code: ::Subject::V3::COLOR_CODE[school][name] }
        end
      end
    end

    mount V1::Root
  end
end
