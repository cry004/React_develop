class Search::Order < Search::Base
  attr_accessor :search_param, :search_value

  def initialize(params)
    @search_param = params.keys.first
    @search_value = params.values.first.try(:gsub, "\s", "+") # メールアドレスの+が消えてしまう対策
  end

  def matches
    results = ::Order.all
    case search_param
    when 'parent_name' then search_by_parent_name
    when 'order_date' then search_by_order_date
    when 'parent_email' then search_by_parent_email
    when 'order_id' then search_by_order_id
    end
  end

  def search_by_parent_name
    family_name_kana, first_name_kana = search_value.try(:split, /\s|\+/)
    parent = ::Parent.find_by(family_name_kana: family_name_kana, first_name_kana: first_name_kana)
    ::Order.where(orderable: parent)
  end

  def search_by_parent_email
    parent = ::Parent.find_by(email: search_value)
    ::Order.where(orderable: parent)
  end

  def search_by_order_id
    # 10桁以上の数値はnilに変換
    # 全角数字を半角数字に変換
    id = search_value.length > 10 ? nil : search_value
    ::Order.where(id: id.try(:tr, "０-９", "0-9"))
  end

  def search_by_order_date
    begin
      # 全角数字を半角数字に変換
      time = Time.parse(search_value.tr("０-９", "0-9"))
    rescue => e
      # 不正な文字列は例外を拾ってTimeオブジェクトを別に生成。検索には引っかからない。
      time = Time.new(0)
    end
    ::Order.where("created_at > (?) AND created_at < (?)", time.beginning_of_day, time.end_of_day)
  end
end
