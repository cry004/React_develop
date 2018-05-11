class Admin::AdminUsersController < Admin::ResourcesController
  before_action :check_action
  def index
    @items = @resources = AdminUser.all.page(params[:page])
    @items = AdminUser.where(email: params["search"]).page(params[:page]) if params["search"]
  end

  def csv_download
    @csv_data = AdminUser.all
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "admin_users-#{Time.zone.now.strftime("%Y%m%d")}.csv", type: :csv
      end
    end
  end

  def edit
    if (admin_user == @admin_user) || (@admin_user.role == "admin")
      super
    else
      redirect_to ({ controller: "admin/questions", action: :index })
    end
  end

  def update
    path = { controller: "admin/admin_users", action: :edit, id: @admin_user.id }
    begin
      @item.profile_update_mode = true
      super
    rescue => e
      json_logger(e.class.to_s, logger_level: :fatal, event_data: { error_type: e.class.to_s, error_message: e.message, error_backtrace: e.backtrace.join("\n") } )
      flash.now["alert"] = "登録情報の一部に不整合があるため正しく保存できませんでした。お問い合わせ先はこちら： #{Settings.teacher_app_contact_tel}"
      redirect_to(path, alert: "登録情報の一部に不整合があるため正しく保存できませんでした。お問い合わせ先はこちら： #{Settings.teacher_app_contact_tel}") and return
    end
  end

  def show
    admin_user = AdminUser.find(params[:id])
    if (admin_user == @admin_user) || (@admin_user.role == "admin")
      super
    else
      redirect_to ({ controller: "admin/questions", action: :index })
    end
  end

  def check_action
    unless @admin_user.role == "admin"
      redirect_to ({ controller: "admin/questions", action: :index }) unless ["edit", "update", "point_request"].include? params[:action]
    else
      redirect_to ({ controller: "admin/admin_users", action: :index }) unless ["index", "new", "show", "create", "csv_download", "update"].include? params[:action]
    end
  end

  def point_request
    path = { controller: "admin/questions", action: :index }
    begin
      if @admin_user.can_point_request?
        @admin_user.exec_point_request
        redirect_to path, notice: "ポイントリクエストを実行しました。"
      else
        redirect_to path, alert: "ポイントリクエストを実行できません。"
      end
    rescue => e
      json_logger(e.class.to_s, logger_level: :fatal, event_data: { error_type: e.class.to_s, error_message: e.message, error_backtrace: e.backtrace.join("\n") } )
      redirect_to path, alert: "ポイントリクエストを実行できません。"
    end
  end

  private

  def update_params
    params.require("admin_user").permit(%w(last_name first_name last_name_kana first_name_kana tel birthday))
  end
end
