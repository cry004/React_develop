module Juku
  class TestLoginController < ApplicationController
    include JukuAPI::Root.helpers

    before_action :ip_restrict

    module Type
      Fist = 'fist'
      Plus = 'plus'
    end

    def create
      type = login_params[:type]
      return render_404 unless type

      klass = switch_chief_with(type)
      return render_404 unless klass

      @current_chief = klass.find_or_create_for_test_login
      create_one_time_token
      update_one_time_token

      @params = {
        token: @one_time_token,
        shin_cd: @current_chief.shin_cd
      }

      redirect_to controller: :login,
                  action:     :create,
                  params:     @params
    end

    private
    def login_params
      params.permit(:type)
    end

    def render_404
      render file: '/public/404.html'
    end

    # NOTE: Allow access only from monstar-lab
    def ip_restrict
      allow_ips = Settings.ip_addresses.monstarlab.to_h.values.flatten
      allow_ips << "::1" if Rails.env.development?
      remote_ip = request.remote_ip

      return render_404 unless allow_ips.include? remote_ip
    end

    def switch_chief_with(type)
      case type
      when Type::Fist then Chief::Fist
      # NOTE: 'classroom' for testing as 'plus' has not been prepared yet.
      when Type::Plus then nil
      else nil
      end
    end
  end
end
