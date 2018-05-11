module Juku
  class LoginController < ApplicationController
    include JukuAPI::Root.helpers

    # 開発効率化のため開発環境でのみ自動的にログインさせる
    before_action :auto_login, if: -> { Rails.env.include?('develop') || Rails.env.include?('staging') }

    def create
      token = login_params[:token]
      return render_403 unless token

      # TODO: Add concerns for fist_api/v1 and juku/login_controller
      is_from_fist = login_params[:shin_cd].present?
      is_from_try_plus = login_params[:tmp_cd].present?

      if is_from_fist
        code = { shin_cd: login_params[:shin_cd] }
      elsif is_from_try_plus
        # TODO: Use get_classroom_id_from(tmp_cd) in helpers for fist_api
        tmp_cd = params[:tmp_cd]

        classroom = Classroom.find_by(tmp_cd: tmp_cd, type: Classroom::Plus::GYTI_KBN)
        return render_403 unless classroom

        code = { classroom_id: classroom.id }
      else
        return render_403
      end

      @current_chief = Chief.find_by(code)
      return render_403 unless @current_chief

      return render_403 unless @current_chief.one_time_token == token

      claim = decode_access_token(token)

      return render_403 unless valid_claim_shin_cd?(claim) if is_from_fist
      return render_403 unless valid_claim_tmp_cd?(claim) if is_from_try_plus

      return render_403 unless valid_nbf?(claim)
      return render_403 if expired?(claim)

      @current_chief.one_time_token = nil
      create_access_token
      update_access_token

      params = { token: "Bearer #{@access_token}" }

      # TODO: Add delegate to model: :Chief
      if is_from_try_plus
        classroom_id = @current_chief.classroom_id
        classroom = Classroom.find_by(id: classroom_id)

        params.merge!(classroom_id: classroom.tmp_cd)
        params.merge!(classroom_name: classroom.name)
      end

      redirect_to action:     :index,
                  controller: :welcome,
                  params:     params
    end

    private

    def login_params
      params.permit(:token, :shin_cd, :tmp_cd)
    end

    def render_403
      render file: '/public/403_juku.html'
    end

    def auto_login
      return if login_params.present?
      @current_chief = Chief.find_or_create_by(id: 1)
      shin_cd = @current_chief.shin_cd

      create_one_time_token
      update_access_token

      params[:token]   = token
      params[:shin_cd] = shin_cd
    end
  end
end
