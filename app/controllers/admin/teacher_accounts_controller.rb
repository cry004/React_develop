class Admin::TeacherAccountsController < ApplicationController
  layout 'teacher_accounts'

  # Basic認証
  before_action if: -> { Rails.env.teacher_staging? || Rails.env.teacher_develop? } do
    remote_ip = request.env['HTTP_X_FORWARDED_FOR']
    addresses = Settings.ip_addresses.monstarlab.to_h
                        .values_at(:ebisu, :shimane).flatten
    unless addresses.include?(remote_ip)
      authenticate_or_request_with_http_basic do |user, pass|
        user == 'try_stg' && pass == 'iiq973gnay'
      end
    end
  end

  before_action if: -> { Rails.env.start_with?('api_') } do
    redirect_to root_path
  end

  def new
    @admin_user = AdminUser.new
    @page_name = ''
  end

  def confirm
    @admin_user = AdminUser.new role: 'answerer', status: true
    @admin_user.assign_attributes(admin_user_params)
    unless @admin_user.valid?
      render :new
    end
    @page_name = '確認'
  end

  def create
    @admin_user = AdminUser.new role: 'answerer', status: true
    AdminUser.transaction do
      if @admin_user.update_attributes(admin_user_params)
        TeacherAccountsMailer.registration_confirmation(@admin_user).deliver_now
        redirect_to :thankyou_admin_teacher_accounts
      else
        render :new
      end
    end
  end

  def thankyou
    @page_name = '完了'
  end

  private

  def admin_user_params
    params.require(:admin_user).permit(
      :first_name,
      :last_name,
      :first_name_kana,
      :last_name_kana,
      :password,
      :password_confirmation,
      :email,
      :tel)
  end
end
