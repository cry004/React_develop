module FistAPI
  class V1 < Grape::API
    format :json
    formatter :json, Grape::Formatter::Rabl
    default_format :json
    version 'v1', using: :path

    rescue_from :all do |e|
      extend API::Root.helpers
      endpoint = env["api.endpoint"]
      logger(e.class, event_data: { error_type: e.class, error_message: e.backtrace.join("\n") }, req: endpoint.request, logger_level: "fatal")
      rack_response Oj.dump({ meta: { error_type: "ServerError", code: 500, error_message: e.backtrace.join("\n") } }), 500
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      extend API::Root.helpers
      endpoint = env["api.endpoint"]
      logger(e.class, event_data: { error_type: e.class, error_message: e.message }, req: endpoint.request, logger_level: "fatal")
      rack_response Oj.dump({ meta: { error_type: "ValidationErrors", code: 400, error_message: e.message } }), 400
    end

    helpers do
      include API::Root.helpers

      # @author tamakoshi
      # @since 20150601
      # FISTもしくはトライプラスのグローバルIPの場合にのみ受け付ける。
      def ip_restrict
        requests  = request.env
        remote_ip = requests['HTTP_X_FORWARDED_FOR'] || requests['REMOTE_ADDR']
        return if remote_ip.in?(Settings.fist_api.allow_ips)
        error 'UnauthorizedIP', 'Un authorized', 401, true, 'error'
      end

      # @author tamakoshi
      # @since 20150804
      def change_root_view_path
        env['api.tilt.root'] = 'app/views/fist_api/'
      end
    end
    helpers API::Helpers::FistHelpers

    resource :users do
      before do
        ip_restrict
        change_root_view_path
      end

      desc '生徒保護者情報登録更新API'
      params do
        requires :KIYKSH_CD,        type: String, allow_blank: false, description: '契約者コード'
        requires :KIYKSH_PSWRD,     type: String, allow_blank: false, description: '契約者パスワード'
        requires :RNRKSK_MAIL,      type: String, allow_blank: false, description: '連絡先メール'
        requires :KIYKSH_SMI,       type: String,                     description: '契約者氏名'
        requires :KIYKSH_KNSMI,     type: String,                     description: '契約者カナ氏名'
        requires :KIYKSH_POST_NO,   type: String,                     description: '契約者郵便番号'
        requires :KIYKSH_ADR_CD,    type: String,                     description: '契約者住所コード'
        requires :KIYKSH_ADR1,      type: String,                     description: '契約者住所1'
        requires :KIYKSH_ADR2,      type: String,                     description: '契約者住所2'
        requires :KIYKSH_TEL_NO,    type: String,                     description: '契約者電話番号'
        requires :SIT_CD,           type: String, allow_blank: false, description: '生徒コード'
        requires :SIT_PSWRD,        type: String, allow_blank: false, description: '生徒パスワード'
        optional :USER_NAME,        type: String,                     description: '生徒ユーザー名'
        requires :SIT_SMI,          type: String,                     description: '生徒氏名'
        requires :SIT_KNSMI,        type: String,                     description: '生徒カナ氏名'
        requires :SEX_KBN,          type: String,                     description: '性別区分'
        requires :BIRTH_DATE_YMD,   type: String,                     description: '生年月日'
        requires :GKNN_CD,          type: String,                     description: '学年コード'
        requires :GKK_CD,           type: String,                     description: '学校コード'
        requires :INS_DT,           type: String,                     description: '登録日時'
        optional :IT_LOGIN_KH_FLAG, type: String,                     description: 'ログイン可否フラグ'
        optional :SIT_STS_KBN,      type: String,                     description: '生徒ステータス区分'
        optional :TMP_CD,           type: String, allow_blank: false, description: '店舗コード'
        optional :GYTI_KBN,         type: String, allow_blank: false, description: '業態区分（01: 家庭・02: 個別・70: トライプラス）',
                                    values: Classroom::Fist::GYTI_KBN + Classroom::Plus::GYTI_KBN
        optional :private_flag,     type: Boolean,                    description: 'プライバシー設定',
                                    default: true
      end
      post '/', rabl: 'v1/default' do
        Rails.logger.info(params['SIT_CD'])

        student_password = student_password(params['SIT_PSWRD'], params['KIYKSH_PSWRD'])

        begin
          Student.create_or_update_from_fist(parent_params(params),
                                             student_params(params),
                                             params['KIYKSH_PSWRD'],
                                             student_password)
        rescue ActiveRecord::RecordInvalid => err
          parent = err.record.try(:parent)
          err.record.errors.messages.merge!(
            parent: {
              kiyksh_cd: parent&.kiyksh_cd,
              email:     parent&.email
            }
          )
          error err.class, err.record.errors, 400, true, 'error'
        end
      end

      desc 'メールアドレス更新API'
      params do
        requires :KIYKSH_CD,   type: String, allow_blank: false, description: '契約者コード'
        requires :RNRKSK_MAIL, type: String, allow_blank: false, description: '連絡先メール'
      end
      put '/', rabl: 'v1/default' do
        begin
          parent = Parent.find_by!(kiyksh_cd: params[:KIYKSH_CD])
          parent.skip_reconfirmation!
          parent.skip_confirmation!
          parent.update!(email: params[:RNRKSK_MAIL])
        rescue ActiveRecord::RecordInvalid => err
          error err.class, err.record.errors, 400, true, 'error'
        rescue ActiveRecord::RecordNotFound => err
          error err.class, err.message, 404, true, 'error'
        end
      end
    end

    resource :parents do
      before do
        ip_restrict
        change_root_view_path
      end

      desc '保護者パスワード更新API'
      params do
        requires :KIYKSH_CD,    type: String, allow_blank: false, description: '契約者コード'
        requires :KIYKSH_PSWRD, type: String, allow_blank: false, description: '契約者パスワード'
      end
      put '/passwords', rabl: 'v1/default' do
        begin
          parent = Parent.find_by!(kiyksh_cd: params[:KIYKSH_CD])
          parent.skip_reconfirmation!
          parent.skip_confirmation!
          parent.update!(password: params[:KIYKSH_PSWRD])
        rescue ActiveRecord::RecordInvalid => err
          error err.class, err.record.errors, 400, true, 'error'
        rescue ActiveRecord::RecordNotFound => err
          error err.class, err.message, 404, true, 'error'
        end
      end
    end

    resource :students do
      before do
        ip_restrict
        change_root_view_path
      end

      desc '生徒パスワード更新API'
      params do
        requires :SIT_CD,    type: String, allow_blank: false, description: '生徒コード'
        requires :SIT_PSWRD, type: String, allow_blank: false, description: '生徒パスワード'
      end
      put '/passwords', rabl: 'v1/default' do
        begin
          student = Student.find_by!(sit_cd: params[:SIT_CD])
          student.update!(password: params[:SIT_PSWRD])
        rescue ActiveRecord::RecordInvalid => err
          error err.class, err.record.errors, 400, true, 'error'
        rescue ActiveRecord::RecordNotFound => err
          error err.class, err.message, 404, true, 'error'
        end
      end
    end

    resource :one_time_tokens do
      # TODO: Add concerns for fist_api/v1 and juku/login_controller
      helpers do
        def generate_one_time_token(**sub)
          JSON::JWT.new(
            iss: 'try-it-juku',
            exp: 5.minutes.since,
            nbf: Time.current,
            sub: sub[:sub]
          ).sign(ACCESS_TOKEN_SIGNATURE, :HS256).to_s
        end

        def get_code_and_sub_from(params)
          # NOTE: params[:SHIN_CD] is sent from FIST and params[:TMP_CD] is sent from TryPlus
          is_from_fist = params[:SHIN_CD].present?
          is_from_try_plus = params[:TMP_CD].present?

          if is_from_fist
            code = sub = { shin_cd: params[:SHIN_CD] }
          elsif is_from_try_plus
            code = { classroom_id: get_classroom_id_from(params[:TMP_CD]) }
            sub  = { tmp_cd: params[:TMP_CD] }
          else
            error "ValidationErrors", "SHIN_CD, TMP_CD are missing, exactly one parameter must be provided", 400, true, "error"
          end

          return code, sub
        end

        private
        def get_classroom_id_from(tmp_cd)
          # `tmp_cd` in Classroom isn't unique. We need to specify it's type.
          # If there is params[:TMP_CD], it can be concluded that it's accessed from TryPlus.
          # So, GYTI_KBN of TryPlus is specified for `type`.
          begin
            Classroom.find_by!(tmp_cd: tmp_cd, type: Classroom::Plus::GYTI_KBN).id
          rescue ActiveRecord::RecordNotFound
            error 'TmpCdInvalid', 'tmp_cd is invalid', 401, true, 'error'
          end
        end
      end

      before do
        ip_restrict
        change_root_view_path
      end

      desc 'ワンタイムトークン取得'
      params do
        optional :SHIN_CD, type: String, allow_blank: false, description: '社員コード（教室長コード）'
        optional :TMP_CD, type: String, allow_blank: false, description: '店舗コード（教室コード）'
        exactly_one_of :SHIN_CD, :TMP_CD
      end
      post '/', rabl: 'v1/one_time_token' do
        begin
          code, sub = get_code_and_sub_from(params)
          @token = generate_one_time_token(sub: sub)

          chief = Chief.find_or_initialize_by(code)
          chief.update!(one_time_token: @token)
        rescue ActiveRecord::RecordInvalid => e
          error e.class, e.record.errors, 400, true, 'error'
        end
      end
    end

    resource :classrooms do
      before do
        ip_restrict
        change_root_view_path
      end

      desc '教室校舎情報追加更新API'
      params do
        requires :TMP_CD,       type: String, allow_blank: false, description: '店舗コード'
        requires :TMP_NM,       type: String, allow_blank: false, description: '店舗名'
        requires :GYTI_KBN,     type: String, allow_blank: false, values: Classroom::Fist::GYTI_KBN + Classroom::Plus::GYTI_KBN,
                                description: '業態区分（01: 家庭・02: 個別・70: トライプラス）'
        requires :TMP_TDFKN_CD, type: String, allow_blank: false, description: '店舗都道府県コード'
        requires :TMP_STS,      type: String, allow_blank: false,
                                description: '店舗状態（01: FIST開校・02: FIST閉校・0: プラス閉校・1: プラス開校・2: プラス準備中）'
      end
      put '/:TMP_CD', rabl: 'v1/default' do
        begin
          klass = case (type = params[:GYTI_KBN])
                  when *Classroom::Fist::GYTI_KBN then Classroom::Fist
                  when *Classroom::Plus::GYTI_KBN then Classroom::Plus
                  end
          classroom = klass.find_or_initialize_by(tmp_cd: params[:TMP_CD])
          classroom.update!(name:            params[:TMP_NM],
                            type:            type,
                            prefecture_code: params[:TMP_TDFKN_CD],
                            status:          params[:TMP_STS])
        rescue ActiveRecord::RecordInvalid => e
          error e.class, e.record.errors, 400, true, 'error'
        end
      end
    end
  end
end
