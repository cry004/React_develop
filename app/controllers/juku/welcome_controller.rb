module Juku
  class WelcomeController < ApplicationController
    include JukuAPI::Root.helpers

    def index
      auth_header = headers['X-Authorization'] || token_params[:token]
      return render_403 unless auth_header

      access_token = auth_header.match(/\ABearer\s+(.+)\z/)&.captures&.first
      return render_403 unless access_token

      claim = decode_access_token(access_token)
      return render_403 unless valid_claim?(claim)
      return render_403 unless valid_nbf?(claim)
      return render_403 unless authorized?(claim)

      response.headers['X-Authorization'] = auth_header if token_params[:token]
    end

    private

    def token_params
      params.permit(:token)
    end

    def render_403
      render file: '/public/403_juku.html'
    end
  end
end
