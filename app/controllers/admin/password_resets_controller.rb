class Admin::PasswordResetsController < ApplicationController
  layout "password_resets"

  def create
    admin_user = AdminUser.find_by_email(params[:email])
    admin_user.send_password_reset if admin_user
    path = { controller: "admin/session", action: :new }
    redirect_to path, :notice => "ご登録のメールアドレスに、パスワードの再設定方法を送信しました。"
  end

  def edit
    @admin_user = AdminUser.find_by(password_reset_token: params[:id])
  end

  def update
    @admin_user = AdminUser.find_by_password_reset_token!(params[:id])
    if @admin_user.password_reset_sent_at < 12.hours.ago
      path = { controller: "admin/session", action: :new }
      redirect_to path, :alert => "パスワード再設定の有効期限が切れました。"
    elsif @admin_user.update_attributes(admin_user_params)
      @admin_user.update_attributes(password_reset_token: nil, password_reset_sent_at: nil)
      redirect_to new_admin_session_path, :notice => "パスワードが再設定されました。"
    else
      render :edit
    end
  end

  private

  def admin_user_params
    params.require(:admin_user).permit(:password, :password_confirmation)
  end
end
