module API
  class Root < Grape::API
    HEADERS = {
      'X-Authorization' => {
        default: 'Bearer ',
        description: "Authenticate. Set 'Bearer ' + 'access_token from Login API response'",
        required: true
      }
    }

    require 'validations/schoolbooks_json_validation'
    require 'validations/combination_of_year_and_subject'
    require 'validations/upload_file_for_without_video_validation'
    require 'validations/combination_of_ranking_and_classroom'

    helpers do
      # @author hasumi
      # @since 20150121
      # PCブラウザ及びスマホネイティブアプリ全てレスポンスJSONのなかのアクセストークンが使われる。
      def create_access_token
        expires = Settings.access_token.hours_to_expire.automatic_login.hours.from_now

        @access_token = JSON::JWT.new(
          { iss: 'try-it-student',
            exp: expires,
            nbf: Time.now, # nbfとはnot beforeの意味です
            sub: { student_id: @current_student.id }
          }
        ).sign(ACCESS_TOKEN_SIGNATURE, :HS256).to_s
        @current_student.update access_token: @access_token
      end

      # @author hasumi
      # @since 20150121
      def authenticate!
        error 'X-AuthorizationHeaderMissing', 'X-Authorization Header is not provided.', 401, true, 'error' unless headers['X-Authorization']
        access_token = headers['X-Authorization'].match(/\ABearer\s+(.+)\z/).try(:[], 1)
        cookie_access_token = cookies['access_token'].try(:gsub, ';', '') # iOSのTryIT履歴で401になる（ヘッダのアクセストークンが古い？）ことがあるので、仕方ないからクッキーも認める
        if cookie_access_token.present? && (access_token != cookie_access_token)
          Rails.logger.debug 'headers : ' + headers.to_s + "\n\n"
        end
        error 'AccessTokenMissing', 'access_token is not provided.', 401, true, 'error' if access_token.blank?
        begin
          claim = JSON::JWT.decode(access_token, ACCESS_TOKEN_SIGNATURE)
        rescue => e
          error(e.class, e.message, 401, true, 'info')
        end
        error 'StudentNotExistException', 'the student claimed is not exist.', 401, true, 'error' unless @current_student = Student.find_by(id: claim['sub']['student_id'], state: 'active')
        if [access_token, cookie_access_token].exclude?(@current_student.access_token)
          cookies[:access_token] = { value: '', domain: '.try-it.jp', path: '/', expires: Time.at(0) } # 2015/10/10までのバグによってユーザ側に残ってしまったクッキーを消す
          error 'AccessTokenInvalid', 'access_token is invalid', 401, true, 'error'
        end
        error 'NbfClaimException', 'nbf claim is invalid.', 401, true, 'error' unless Time.at(claim['nbf']) <= Time.now.since(3.seconds) # nbfとはnot beforeの意味です
        if Time.at(claim['exp']) < Time.now || @current_student.access_token.nil?
          error 'Unauthorized', 'the access_token provided is expired. need to sign in.', 401, true, 'error'
        end
      end

      # @author hasumi
      # @since 20150120
      def error(type = 'InternalServerError', message = 'unknown error occurred.', code = 500, logger_flag = true, logger_level = 'fatal')
        logger(type, event_data: { error_type: type, error_message: message }, logger_level: logger_level) if logger_flag
        if code == 204
          error!({ meta: { error_type: type, code: code, error_message: message } }, 200)
        else
          error!({ meta: { error_type: type, code: code, error_message: message } }, code)
        end
      end

      # @author tamakoshi
      # @since 20150205
      def logger(event_name, event_data: {}, user: @current_student, logger_level: 'info', req: request)
        locals = { request: req, user: user, event_name: event_name, event_data: event_data }
        json   = Rabl.render(false, 'log/event_log', view_path: 'app/views/api', format: :json, locals: locals)
        Rails.logger.send(logger_level, json)
      end

      # @author tamakoshi
      # @since 20150408
      # useragentの判定を行う
      def request_variant(req = request)
        ua = req.user_agent
        @player_type = if Woothee.parse(ua)[:category] == :smartphone
                         unless Woothee.parse(ua)[:name] == 'UNKNOWN'
                           case ua
                           when /iPhone|iPad/
                             :mp4_video
                           when /Android/
                             :mp4_video
                           else
                             :mp4_video
                           end
                         else
                           case Woothee.parse(ua)[:os]
                           when 'iOS'
                             :m3u8_video
                           when 'Android'
                             :m3u8_video
                           else
                             :mp4_video
                           end
                         end
        else
          #:mp4_flash
          :mp4_video
        end
      end

      # useragentからosを判定する
      # iphone, ipod, ipadの場合すべてiosとする。
      def judge_os(req = request)
        os = Woothee.parse(req.user_agent)[:os].downcase
        case os
        when 'iphone', 'ipod', 'ipad' then 'ios'
        else os
        end
      end

      def is_pc?(req = request)
        Woothee.parse(req.user_agent)[:category] == :pc
      end

      # @author tamakoshi
      # @since 20150225
      def current_student_school
        @current_student_school ||= @current_student.try(:school)
      end
    end

    mount V3 # FIXME: remove me! https://rdm.try-it.jp/issues/4714
    mount V5
  end
end
