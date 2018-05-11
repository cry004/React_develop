class Admin::AccountController < Admin::BaseController
  layout 'admin/session'

  skip_before_filter :reload_config_and_roles, :authenticate, :set_locale

  before_filter :sign_in?, except: [:forgot_password, :send_password, :show]
  before_filter :new?, only: [:forgot_password, :send_password]

  def new
  end

  def create
    user = Typus.user_class.generate(email: admin_user_params[:email])
    redirect_to user ? { action: 'show', id: user.token } : { action: :new }
  end

  def forgot_password
  end

  def send_password
    admin_user = AdminUser.find_by_email(params["admin_user"]["email"])
    admin_user.send_password_reset if admin_user
    redirect_to new_admin_session_path, :notice => "ご登録のメールアドレスに、パスワードの再設定方法を送信しました。"
  end

  def show
    begin
      typus_user = Typus.user_class.find_by_token!(params[:id])
      session[:typus_user_id] = typus_user.id
      redirect_to params[:return_to] || { controller: "/admin/#{Typus.user_class.to_resource}", action: 'edit', id: typus_user.id }
    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_session_path
    end
  end

  private

  def sign_in?
    redirect_to new_admin_session_path unless zero_users
  end

  def new?
    redirect_to new_admin_account_path if zero_users
  end
end
