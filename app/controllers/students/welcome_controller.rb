class Students::WelcomeController < Students::ApplicationController
  def index
    if request.subdomain[0..2] == 'api' \
      && Rails.env[0..2] == 'api' \
      && Settings.ip_addresses.monstarlab.to_h.values.flatten.exclude?(remote_ip)
      redirect_to Settings.hostname.student
    end
  end

  def reset_session
    cookies.delete(:access_token) if cookies[:access_token].present?
    redirect_to :root
  end
end
