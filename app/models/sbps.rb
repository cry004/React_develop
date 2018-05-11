# @author hasumi
# @since 20150529
# ソフトバンク・ペイメント・サービス
module SBPS
  RequestMethods = {
    create_creditcard:  {id: 'MG02-00101-101', description: '保護者のクレカをSBPSに保存する'},
    destroy_creditcard: {id: 'MG02-00103-101', description: '保存済のクレカ情報を削除'},
    get_creditcard:     {id: 'MG02-00104-101', description: 'SBPSに保存したカード情報を取得'},
    request_credit:     {id: 'ST01-00111-101', description: '与信枠を要求'},
    confirm_credit:     {id: 'ST02-00101-101', description: '要求OKに対し与信枠を確定'},
    destroy_credit:     {id: 'ST02-00303-101', description: '与信枠を削除（返金）'}
  }

  Cardbrands = {
    'J' => 'JCBカード',
    'V' => 'Visa',
    'M' => 'MasterCard',
    'A' => 'AMEX',
    'D' => 'Diners',
    'X' => 'その他'
  }

  class Base
    attr_reader :merchant_id, :service_id, :cust_code

    # @author hasumi
    # @since 20150529
    def initialize(params = {})
      @merchant_id = Settings.sbps.merchant_id
      @service_id = Settings.sbps.service_id
      reset_xml
    end

    def reset_xml
      @xml = Builder::XmlMarkup.new indent: 0
      @xml.instruct! :xml, encoding: "Shift-JIS"
    end

    private

    attr_accessor :xml

    # @author hasumi
    # @since 20150529
    # 一度つくったらreset_request_dateを呼ぶまで更新されない
    def request_date
      @request_date ||= SBPS::Card.yyyymmddhhmmss
    end

    # @author hasumi
    # @since 20150529
    def reset_request_date
      @request_date = nil
    end

    # @author hasumi
    # @since 20150529
    # @refer A001_システム仕様書（API編）1.5.9.pdf の 6ページ
    def self.encrypt(data)
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
      cipher.encrypt
      cipher.iv = Settings.sbps.cipher.initialization_vector
      cipher.key = Settings.sbps.cipher.secret_key
      output = cipher.update(data)
      output << cipher.final
      Base64.encode64(output).sub(/\n/, '')
    end

    # @author hasumi
    # @since 20150529
    # @refer A001_システム仕様書（API編）1.5.9.pdf の 6ページ
    def self.decrypt(ciphertext)
      crypto = ::Mcrypt.new(:tripledes, :cbc)
      mcrypt_key = Settings.sbps.cipher.secret_key.dup
    # キー長が足りない分は \0 で埋める
      if mcrypt_key.length < crypto.key_size
        mcrypt_key = mcrypt_key.ljust(crypto.key_size, "\0")
      end
      crypto.key = mcrypt_key
      crypto.iv = Settings.sbps.cipher.initialization_vector
      crypto.padding = :zeros
      plaintext = crypto.decrypt(::Base64.decode64 ciphertext)
      plaintext.strip.force_encoding('utf-8')
    end

    # @author hasumi
    # @since 20150529
    # リクエスト日時
    def self.yyyymmddhhmmss
      Time.new.strftime('%Y%m%d%H%M%S')
    end

    # @author hasumi
    # @since 20150529
    # チェックサム
    def self.sps_hashcode(*data)
      data << Settings.sbps.hashkey
      Digest::SHA1.hexdigest(data.join)
    end

    # # @author hasumi
    # # @since 20150529
    # # SPBSに投げるための顧客コードをparent.idを元につくる
    # # @return [String] 「TP（固定）＋18桁化したID」計20桁が返る
    # def cust_code
    #   "TP#{format("%018d", @parent.id)}"
    # end

    # @author hasumi
    # @since 20150529
    # 通信実行
    # @param log [Boolean] ログをDB保存するか
    def post(params)
      reset_request_date
      faraday = Faraday.new(url: Settings.sbps.endpoint.domain) do |builder|
        builder.adapter :net_http
        builder.basic_auth Settings.sbps.basic_auth.username, Settings.sbps.basic_auth.password
      end

      request_body = @xml.encode('Shift_JIS').sub(/\<encode\>Shift_JIS\<\/encode\>$/, '')
      begin
        response = faraday.post do |request|
          request.url Settings.sbps.endpoint.path
          request.headers['Content-Type'] = 'text/xml'
          request.body = request_body
        end
        if response.success?
          doc = Nokogiri::XML(response.body.encode('UTF-8'))
          params[:request_body] = request_body
          params[:response] = doc
          log(params)
          if doc.xpath('//res_result').text == 'OK'
            return doc
          else
            Rails.logger.error response.body
            return false
          end
        else
          Rails.logger.error response.body
          return false
        end
      rescue => e
        Rails.logger.fatal [e.class, e].join(" : ") + "\n" + e.backtrace.join("\n")
        return false
      end
    end

    # @author hasumi
    # @since 20150601
    # 記録する
    def log(params)
      return nil unless params[:log]
      request_body, response = params[:request_body], params[:response]
      request_method = RequestMethods.find do |key, value|
        value[:id] == Nokogiri::XML(request_body).xpath('/sps-api-request/@id').first.value
      end.first
      SbpsLog.create! parent: @parent,
        amount: params[:amount],
        request_method: request_method,
        credit: params[:credit],
        request: request_body,
        response: response,
        result: response.xpath('//res_result').text,
        sps_transaction_id: response.xpath('//res_sps_transaction_id').text,
        tracking_id: response.xpath('//res_tracking_id').text,
        err_code: response.xpath('//res_err_code').text
    end

    # @author hasumi
    # @since 20150529
    # SPBSに投げるための顧客コードをparent.idを元につくる
    # @return [String] 「TP（固定）＋MSDPX（のどれか）＋17桁化したID」計20桁が返る
    # 【重要】リリース後の変更不可
    def cust_code
      "TP#{envkey}#{format("%017d", @parent.id)}"
    end

    private

    def envkey
      case Rails.env
      when 'development'
        'M'
      when 'api_staging', 'teacher_staging'
        'S'
      when 'api_develop', 'teacher_develop'
        'D'
      when 'api_production', 'teacher_production'
        'P'
      else
        'X'
      end
    end
  end

  class Card < SBPS::Base
    include ActiveModel::Model
    extend ActiveModel::Naming

    attr_accessor :parent, :cc_number, :cc_expiration, :cc_expiration_year, :cc_expiration_month, :security_code, :cardbrand

    validates :cc_number, presence: true, format: { with: /\A\d{14,16}\z/i }
    validates :cc_expiration_year, presence: true
    validates :cc_expiration_month, presence: true
    validates :security_code, presence: true, format: { with: /\A\d{3,4}\z/i }

    define_model_callbacks :save
    before_save { self.valid? }

    # @author hasumi
    # @since 20150529
    # 登録済みクレカ情報を取得
    def get
      @xml.tag! 'sps-api-request', id: RequestMethods[:get_creditcard][:id] do
        @xml.merchant_id @merchant_id
        @xml.service_id  @service_id
        @xml.cust_code   cust_code
        @xml.response_info_type '2'      # カード番号下4桁以外はマスク（*）
        @xml.pay_option_manage do
          @xml.cardbrand_return_flg '1'
        end
        @xml.encrypted_flg '1'
        @xml.request_date request_date
        @xml.sps_hashcode Card.sps_hashcode(@merchant_id, @service_id, cust_code, '2', '1', '1', request_date)
      end
      if doc = post(log: false)
        info = doc.xpath('//res_pay_method_info')
        @cc_number =     Card.decrypt(info.xpath('cc_number').text)
        @cc_expiration = Card.decrypt(info.xpath('cc_expiration').text)
        @cc_expiration_year = @cc_expiration[0..3]
        @cc_expiration_month = @cc_expiration[4..5]
        @cardbrand = Cardbrands[Card.decrypt(info.xpath('cardbrand_code').text)]
      else
        false
      end
    end

    # @author hasumi
    # @since 20150529
    # クレカ情報を新規登録
    def update_attributes(params)
      assign_attributes(params)
      run_callbacks :save do
        @xml.tag! 'sps-api-request', id: RequestMethods[:create_creditcard][:id] do
          @xml.merchant_id @merchant_id
          @xml.service_id  @service_id
          @xml.cust_code   cust_code
          @xml.pay_method_info do
            @xml.cc_number     Card.encrypt(@cc_number)
            @xml.cc_expiration Card.encrypt(@cc_expiration_year + @cc_expiration_month)
            @xml.security_code Card.encrypt(@security_code)
          end
          @xml.encrypted_flg '1'
          @xml.request_date request_date
          @xml.sps_hashcode Card.sps_hashcode(@merchant_id, @service_id, cust_code, @cc_number, @cc_expiration_year + @cc_expiration_month, @security_code, '1', request_date)
        end
        params[:log] = true
        if post(params)
          parent.update_attribute :creditcard, true
        else
          false
        end
      end
    end

    # @author hasumi
    # @since 20150529
    # クレカ情報を削除
    def destroy
      @xml.tag! 'sps-api-request', id: RequestMethods[:destroy_creditcard][:id] do
        @xml.merchant_id @merchant_id
        @xml.service_id  @service_id
        @xml.cust_code   cust_code
        @xml.request_date request_date
        @xml.sps_hashcode Card.sps_hashcode(@merchant_id, @service_id, cust_code, request_date)
      end
      if post(log: true)
        parent.update_attribute :creditcard, false
      else
        false
      end
    end

    private

    def assign_attributes(params)
      params.keys.each do |key|
        self.send("#{key}=", params[key])
      end
    end
  end

  class Credit < SBPS::Base
    attr_accessor :parent

    # @author hasumi
    # @since 20150529
    # 与信リクエスト。成功後ただちに与信確定を行う必要あり
    def request_credit(params)
      order_id = order_id_by(params[:credit].id)
      free1 = '受注ID数字＝注文ID'.encode('Shift_JIS')
      free2 = '顧客ID数字＝保護者ID'.encode('Shift_JIS')
      if params[:student].present? # studentがあるのはポイント上限設定の場合。ない場合は問題集購入
        item_id   = item_id_by(params[:student].id)
        item_name = 'ポイント上限与信'.encode('Shift_JIS')
        free3     = '商品ID数字＝生徒ID'.encode('Shift_JIS')
      else
        item_id   = 'NULL'
        item_name = '問題集購入与信'.encode('Shift_JIS')
        free3     = ''.encode('Shift_JIS')
      end
      @xml.tag! 'sps-api-request', id: RequestMethods[:request_credit][:id] do
        @xml.merchant_id @merchant_id
        @xml.service_id  @service_id
        @xml.cust_code   cust_code
        @xml.order_id    order_id
        @xml.item_id     item_id
        @xml.item_name   Base64.encode64(item_name)
        @xml.amount      params[:amount]
        @xml.free1       Base64.encode64(free1)
        @xml.free2       Base64.encode64(free2)
        @xml.free3       Base64.encode64(free3)
        @xml.pay_option_manage do
          @xml.cust_manage_flg '0'
        end
        @xml.encrypted_flg   '1'
        @xml.request_date request_date
        @xml.sps_hashcode Card.sps_hashcode(@merchant_id, @service_id, cust_code, order_id, item_id, item_name, params[:amount], free1, free2, free3, '0', '1', request_date)
      end
      params[:log] = true
      if doc = post(params)
        { sps_transaction_id: doc.xpath('//res_sps_transaction_id').text,
          sps_tracking_id: doc.xpath('//res_sps_tracking_id').text }
      else
        false
      end
    end

    # @author hasumi
    # @since 20150529
    # 与信確定
    def confirm_credit(params)
      @xml.tag! 'sps-api-request', id: RequestMethods[:confirm_credit][:id] do
        @xml.merchant_id @merchant_id
        @xml.service_id  @service_id
        @xml.sps_transaction_id   params[:sps_transaction_id]
        @xml.request_date request_date
        @xml.sps_hashcode Card.sps_hashcode(@merchant_id, @service_id, params[:sps_transaction_id], request_date)
      end
      params[:log] = true
      if doc = post(params)
        { sps_transaction_id: doc.xpath('//res_sps_transaction_id').text,
          sps_tracking_id: doc.xpath('//res_sps_tracking_id').text }
      else
        false
      end
    end

    private

    def order_id_by(credit_id)
      "TC#{envkey}#{format("%017d", credit_id)}"
    end

    def item_id_by(student_id)
      "TS#{envkey}#{format("%017d", student_id)}"
    end
  end
end
