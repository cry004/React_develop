class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # @author hasumi
  # @since 20150305
  force_ssl if: :ssl_configured?

  # Nginxでベーシック認証かけると何度もauthを聞かれる
  # （temp_siteにもかけてるせいか？わからん）ので、
  # アプリ側で認証する
  # @since 20150226
  # /api/v1にも認証かかっているとうまく動かないので、ここだけにした
  # @since 20150331
  # 特定IPならBasic認証なしにした（ステージングとdevelopのみ）
  before_action if: -> { Rails.env.end_with?('_develop', '_staging') } do
    addresses = Settings.ip_addresses.monstarlab.to_h
                        .values_at(:ebisu, :shimane).flatten
    unless addresses.include?(remote_ip)
      authenticate_or_request_with_http_basic do |user, pass|
        user == 'try_stg' && pass == 'iiq973gnay'
      end
    end
  end

  private

  # @author hasumi
  # @since 20151110
  # parent用
  def after_sign_in_path_for(resource)
    if current_parent.halfway_signup?
      "#{Settings.hostname.www}/students/signup_students_count"
    else
      main_path
    end
  end

  # @author hasumi
  # @since 20151110
  # parent用
  def after_sign_out_path_for(resource)
    new_parent_session_path
  end

  # @author hasumi
  # @since 20150305
  def ssl_configured?
    !Rails.env.development? && !Rails.env.test?
  end

  def remote_ip
    request.env["HTTP_X_FORWARDED_FOR"].present? ? request.env["HTTP_X_FORWARDED_FOR"].split(',')[0] : request.remote_ip
  end
end
