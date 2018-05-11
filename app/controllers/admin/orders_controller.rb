class Admin::OrdersController < Admin::ResourcesController
  def index
    add_resource_action("見る", { action: "show" })
    @state_name_options = state_name_options
    @select_method_options = select_method_options
    if search_param.present?
      @order = Search::Order.new(search_param)
      @items = @resources = @order.matches.where.not(category: ["shipping_fee", "question"]).order("created_at DESC").page(params[:page]).per(100)
    else
      @order_state_fileter_selected, states = set_states_and_order_state_fileter_selected
      @items = @resources = Order.includes(:orderable, :credit).where(state: states).where.not(category: ["shipping_fee", "question"]).order("created_at DESC").page(params[:page]).per(100)
    end
  end

  def unsettle
    order = Order.find(params[:id])
    path = { controller: "admin/orders", action: :index }
    if validate_english_schoolbook_code_param && order.can_unsettle?
      order.update_attributes! english_schoolbook_code: params[:english_schoolbook_code].to_i
      order.unsettle
      redirect_to path, notice: "注文 id: #{params[:id]}の教科書を設定し、発送可にしました。"
    else
      redirect_to path, alert: "注文 id: #{params[:id]}を教科書を設定し、発送可にすることができません。"
    end
  end

  def return_ordered
    order = Order.find(params[:id])
    path = { controller: "admin/orders", action: :index }
    if order.can_return_ordered?
      order.return_ordered
      redirect_to path, notice: "注文 id: #{params[:id]}を発送不可にしました。"
    else
      redirect_to path, alert: "注文 id: #{params[:id]}を発送不可にできません。"
    end
  end

  def settle
    order = Order.find(params[:id])
    path = { controller: "admin/orders", action: :index }
    if order.can_settle?
      order.settle
      redirect_to path, notice: "注文 id: #{params[:id]}を発送済みにしました。"
    else
      redirect_to path, alert: "注文 id: #{params[:id]}を発送済みにできません。"
    end
  end

  def return_unsettled
    order = Order.find(params[:id])
    path = { controller: "admin/orders", action: :index }
    if order.can_return_unsettled?
      order.return_unsettled
      redirect_to path, notice: "注文 id: #{params[:id]}を発送可に戻しました。"
    else
      redirect_to path, alert: "注文 id: #{params[:id]}を発送可に戻すことができません。"
    end
  end

  def csv_download_for_textbook
    path = { controller: "admin/orders", action: :index }
    if params["from_date"].present? && params["to_date"].present?
      from_date = Time.zone.parse(params["from_date"]).beginning_of_day
      to_date = Time.zone.parse(params["to_date"]).end_of_day
      state = @admin_user.role == "admin" ? ["ordered", "unsettled"] : "unsettled"
      @csv_data = Order.includes(:orderable).where(state: state).where(category: "textbook").where("created_at >= (?) AND created_at <= (?)", from_date, to_date).order("created_at DESC")
      send_data render_to_string("admin/orders/textbooks_csv_download.csv"), filename: "textbooks_orders_#{from_date.strftime("%Y%m%d")}-#{to_date.strftime("%Y%m%d")}.csv", type: :csv
    else
      redirect_to path
    end
  end

  def csv_download_for_credit
    path = { controller: "admin/orders", action: :index }
    if params["from_date"].present? && params["to_date"].present?
      from_date = Time.zone.parse(params["from_date"]).beginning_of_day
      to_date = Time.zone.parse(params["to_date"]).end_of_day
      @csv_data = []
      # 質問作成月と注文作成月が違う場合があるのでorders.created_atでフィルタリング
      @csv_data += Question.includes(:order, { student: :parent}).references(:order).where("orders.state" => "settled").where("orders.created_at >= (?) AND orders.created_at <= (?)", from_date, to_date)
      @csv_data += Order.includes(:orderable).where(category: "textbook").where.not(state: "failed").where("created_at >= (?) AND created_at <= (?)", from_date, to_date).order("created_at DESC")
      send_data render_to_string("admin/orders/credit_csv_download.csv"), filename: "credit_orders_#{from_date.strftime("%Y%m%d")}-#{to_date.strftime("%Y%m%d")}.csv", type: :csv
    else
      redirect_to path
    end
  end

  def batch
    order_ids = params["change_state_flag"].try(:keys)
    orders = Order.where(id: order_ids)
    path = { controller: "admin/orders", action: :index }
    if order_ids && send_method_name && orders.all? { |order| order.send("can_#{send_method_name}?") }
      orders.find_each { |order| order.send(send_method_name) }
      redirect_to path, notice: "注文 ids: #{order_ids}を#{select_notice_message(send_method_name)}"
    elsif orders.empty?
      redirect_to path, alert: "一括処理時に注文が一つも選択されていません。"
    else
      alert_message = select_method_options.invert[params["select_method"]]
      redirect_to path, alert: "選択した注文を#{alert_message}にすることができません。"
    end
  end

  def cancel
    order = Order.find(params[:id])
    path = { controller: "admin/orders", action: :index }
    if order.can_cancel?
      order.cancel
      redirect_to path, notice: "注文 id: #{order.id}をキャンセルしました。"
    else
      redirect_to path, alert: "注文 id: #{order.id}をキャンセルできません。"
    end
  end

  private

  def validate_english_schoolbook_code_param
    params[:english_schoolbook_code].to_i.in? Settings.english_schoolbook_code.to_hash.values
  end

  def send_method_name
    case params["select_method"]
    when "settle" then "settle"
    when "return_unsettled" then "return_unsettled"
    when "cancel" then "cancel"
    end
  end

  def search_param
    params.select{|k, v| k.in?(["parent_name", "order_date", "parent_email", "order_id"])}
  end

  def state_name_options
    case @admin_user.role
    when "admin"
      I18n.t("activerecord.state_machines.order.state.states").invert.merge({ "すべて" => :all })
    when "telephone_communicator"
      { "発送不可" => :ordered, "発送可" => :unsettled, "発送済み" => :settled, "キャンセル" => :canceled }
    else
      { "発送不可" => :ordered, "発送可" => :unsettled, "発送済み" => :settled }
    end
  end

  def set_states_and_order_state_fileter_selected
    if params["state"].present?
      case params["state"]
      when "all" then [:all, Order.new.state_paths.to_states]
      else
        [params["state"], params["state"]]
      end
    else
      case @admin_user.role
      when "telephone_communicator" then [:ordered, :ordered]
      when "shipping_manager" then [:unsettled, :unsettled]
      when "admin" then [:all, Order.new.state_paths.to_states]
      end
    end
  end

  def select_method_options
    case @admin_user.role
    when "admin"
      { "発送済みにする" => "settle", "発送可に戻す" => "return_unsettled", "キャンセルする" => "cancel" }
    when "telephone_communicator"
      { "キャンセルする" => "cancel" }
    else
      { "発送済みにする" => "settle", "発送可に戻す" => "return_unsettled"}
    end
  end

  def select_notice_message(select_method)
    case select_method
    when "settle"
      "発送済みにしました。"
    when "return_unsettled"
      "発送可に戻しました。"
    when "cancel"
      "キャンセルしました。"
    end
  end
end
