class Search::Student < Search::Base
  attr_accessor :search_param, :search_value, :params
  ATTRIBUTES = %w(
    sit_cd
    usrname
    family_name_kana
    first_name_kana
    full_name_kana
    parent_email
    created_date
  )

  ATTRIBUTES_CURRENT_MEMBER_TYPE = [['tryit', 'tryit'], ['fist', 'fist'], ['fc', 'fc'], ['tester', 'tester']]

  ATTRIBUTES_STATE = [['pending', 'pending'], ['active', 'active'], ['inactive', 'inactive']]

  OPTIONS_FOR_SELECT = {}

  ATTRIBUTES.each do |attribue|
    OPTIONS_FOR_SELECT[attribue] =
      I18n.t(attribue, scope: 'search_value.student')
  end

  def initialize(params)
    @search_param = params.keys.first
    @search_value = params.values.first.try(:gsub, ' ', '+')
    self.params = params
  end

  def matches
    case search_param
    when 'family_name_kana' then search_by_family_name_kana
    when 'first_name_kana'  then search_by_first_name_kana
    when 'full_name_kana'   then search_by_full_name_kana
    when 'created_date'     then search_by_created_date
    when 'parent_email'     then search_by_parent_email
    when 'usrname'          then search_by_usrname
    when 'sit_cd'           then search_by_sit_cd
    when 'current_member_type' then search_by_current_member_type
    end
  end

  def search_by_segment
    ::Student.of_city(params[:prefecture_codes])
             .of_member_types(params[:member_types])
             .of_gknn_cds(params[:gknn_cds])
  end

  def search_by_family_name_kana
    ::Student.where(family_name_kana: search_value)
  end

  def search_by_first_name_kana
    ::Student.where(first_name_kana: search_value)
  end

  def search_by_full_name_kana
    family_name_kana, first_name_kana =
      search_value.try(:split, /\s|\+/)
    ::Student.where(family_name_kana: family_name_kana,
                    first_name_kana: first_name_kana)
  end

  def search_by_usrname
    ::Student.where(username: search_value)
  end

  def search_by_parent_email
    parent = ::Parent.find_by(email: search_value)
    ::Student.where(parent: parent)
  end

  def search_by_created_date
    begin
      # 全角数字を半角数字に変換
      time = Time.parse(search_value.tr('０-９', '0-9'))
    rescue => e
      # 不正な文字列は例外を拾ってTimeオブジェクトを別に生成
      # 検索には引っかからない。
      time = Time.new(0)
    end
    ::Student.where('created_at > (?) AND created_at < (?)',
                    time.beginning_of_day, time.end_of_day)
  end

  def search_by_sit_cd
    ::Student.where(sit_cd: search_value)
  end

  def search_by_current_member_type
    current_member_type = params[:current_member_type]
    state = params[:state]
    first_values_params_present = values_params.first.present?
    second_params_value_present = values_params.second.present?
    if first_values_params_present && second_params_value_present
      ::Student.where('current_member_type = (?) AND state = (?)',
                      current_member_type, state)
    elsif first_values_params_present || second_params_value_present
      ::Student.where('current_member_type = (?) OR state = (?)',
                      current_member_type, state)
    else
      ::Student.all
    end
  end

  def values_params
    params.values
  end
end
