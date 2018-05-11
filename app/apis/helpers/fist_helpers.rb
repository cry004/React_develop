module Helpers::FistHelpers
  # @author tamakoshi
  # @since 20150603
  # FISTからもらうデータをTry-ItのParentに保存できるようにする。
  def parent_params(params)
    {
      kiyksh_cd: params["KIYKSH_CD"],
      email: email(params["RNRKSK_MAIL"]&.downcase, params["KIYKSH_CD"]),
      family_name: name_split(params["KIYKSH_SMI"])[0] || ".",
      first_name: name_split(params["KIYKSH_SMI"])[1] || ".",
      family_name_kana: (name_split(params["KIYKSH_KNSMI"])[0] || ".").clean_string, # ひらがなや半角カナが入ってこないようにする
      first_name_kana: (name_split(params["KIYKSH_KNSMI"])[1] || ".").clean_string,  # ひらがなや半角カナが入ってこないようにする
      tel: tell(params["KIYKSH_TEL_NO"]),
      zip: zip(params["KIYKSH_POST_NO"]),
      city: city(params["KIYKSH_POST_NO"]),
      prefecture_code: prefecture_code(params["KIYKSH_ADR_CD"]),
      address1: address(params["KIYKSH_ADR1"]),
      address2: params["KIYKSH_ADR2"],
      relationship_code: 99 # FISTのデータには続柄のデータがないためすべて"その他"で登録する
    }.with_indifferent_access
  end

  # @author tamakoshi
  # @since 20150603
  # FISTからもらうデータをTry-ItのStudentに保存できるようにする。
  def student_params(params)
    {
      username: username(params["SIT_CD"], params["USER_NAME"]),
      school: "c",
      sit_cd: params["SIT_CD"],
      schoolbooks: Settings.default_schoolbooks_settings["c"].to_hash,
      gknn_cd: convert_of_invalid_gknn_cd(params["GKNN_CD"]),
      family_name: name_split(params["SIT_SMI"])[0] || ".",
      first_name: name_split(params["SIT_SMI"])[1] || ".",
      family_name_kana: (name_split(params["SIT_KNSMI"])[0] || ".").clean_string, # ひらがなや半角カナが入ってこないようにする
      first_name_kana: (name_split(params["SIT_KNSMI"])[1] || ".").clean_string,  # ひらがなや半角カナが入ってこないようにする
      sex: params["SEX_KBN"].present? ? Student::SEX_CODE[params["SEX_KBN"]] : "male",
      state: "active",
      birthday: birthday(params["BIRTH_DATE_YMD"]),
      school_name: ".",
      original_member_type: "fist",
      current_member_type: "fist",
      it_login_kh_flag: params["IT_LOGIN_KH_FLAG"] || "1",
      ins_dt: register_date(params["INS_DT"]),
      current_month: Time.now.strftime("%Y%m").to_i,
      classroom: classroom(params['TMP_CD'], params['GYTI_KBN']),
      private_flag: params['private_flag']
    }.with_indifferent_access
  end

  # @author tamakoshi
  # @since 20150603
  # デバイスが内部的に使用している暗号化メソッドを使用。
  # https://github.com/plataformatec/devise/blob/master/lib/devise/encryptor.rb
  def self.password_encryptor(password)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine::DEFAULT_COST
    BCrypt::Password.create(password.downcase, cost: cost).to_s
  end

  # @author tamakoshi
  # @since 20150603
  # 生徒のパスワードはない場合が存在するらしいので、ない場合契約者のパスワードを返す。
  def student_password(sit_password, kiyksh_password)
    (sit_password.nil? || sit_password.empty? || sit_password.match(/　| /)) ? kiyksh_password.downcase : sit_password.downcase
  end

  private

    # @author tamakoshi
    # @since 20150603
    # FISTの氏名データは基本全角スペースで苗字と名前を分けているが、半角スペースや他にも全角スペース+半角スペースで
    # 分けられていたりするのでそれに対応して、苗字と名前を分ける
    # 名前がない場合は、.を保存する
  def name_split(name)
    name ? name.split(/　| |・/).select {|string| string.present? } : [".", "."]
  end

    # @author tamakoshi
    # @since 20150603
    # FIST契約者のメールアドレスがない場合、契約者コードから仮のメールアドレスを作成する.
    # メールアドレスカラムの空は、nilだったり、半角スペースだったり、全角スペースだったりするのでそれに対応。
  def email(email, kiyksh_cd)
    (email.nil? || email.empty? || email.match(/　| /) || email.size < 5 ) ? "adhoc+#{kiyksh_cd}@try-it.jp" : email
  end

    # @author tamakoshi
    # @since 20150625
  def username(sit_cd, username)
    username.present? ? username : sit_cd
  end

    # @author tamakoshi
    # @since 20150603
    # FIST契約者の住所コードの先頭2行をprefecture_codeとして返す。住所コードがない場合は00を返す。
  def prefecture_code(kiyksh_adr_cd)
    kiyksh_adr_cd.present? ? kiyksh_adr_cd[0..1] : 00
  end

  def register_date(date_string)
    date_string.present? ? Time.parse(date_string).to_datetime : nil
  end

    # @author tamakoshi
    # @since 20150603
    # 生徒の誕生日データがない場合があるので、その場合は, Date.new(0)を返す。
  def birthday(birthday_string)
    birthday_string.present? ? birthday_string : Date.new(2000, 1, 1)
  end

    # @author tamakoshi
    # @since 20150711
    # adressの記入がなかった場合全角スペースを保存する
  def address(address_string)
    address_string.present? ? address_string : "."
  end

    # @author tamakoshi
    # @since 20150711
    # telの記入がなかった場合00000000000を保存する
  def tell(tell_string)
    (tell_string.nil? || tell_string.empty? || tell_string.match(/　| /)) ? "00000000000" : tell_string.gsub(/[-ー]/, "")
  end

    # @author tamakoshi
    # @since 20150711
    # 郵便番号の長さが7桁以下(3桁や5桁の場合),先頭に0を埋めて7桁にする
    # 郵便番号がない場合は0000000で保存する。
  def zip(zip_string)
    if zip_string.present?
      zip_string.gsub!(/[-ー 　]/, "")
      if zip_string.size <= 7
        lack_of_num = (7 - zip_string.size)
        (lack_of_num == 0) ? zip_string : ("0" * lack_of_num + zip_string)
      else
        zip_string[0..6]
      end
    else
      "0000000"
    end
  end

    # @author tamakoshi
    # @since 20150711
    # cityを保存する
  def city(post_no)
    post_no.present? ? (ZipCodeJp.find(post_no).try(:city) || ".") : "."
  end

    # @author tamakoshi
    # @since 20151008
    # GknnCd::Mapに含まれないgknn_cdを99(その他)に変換するメソッド
  def convert_of_invalid_gknn_cd(gknn_cd)
    GknnCd::Map.keys.include?(gknn_cd) ? gknn_cd : "99"
  end

  def classroom(tmp_cd, type)
    return if [tmp_cd, type].all?(&:blank?)
    Classroom.find_by!(tmp_cd: tmp_cd, type: type)
  end
end
