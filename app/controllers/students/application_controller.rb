class Students::ApplicationController < ApplicationController
  layout 'students_application'

  # @author hasumi
  # @since 20150213
  # SPとPCの振り分け
  before_filter do
    ua = request.user_agent
    request.variant = if Woothee.parse(ua)[:category] == :smartphone
                        if ua.match('iPad') || ( ua.match('Android') && !ua.match('Mobile') )
                          :desktop # 混乱を避けるためtabletにはしない
                        else
                          :desktop # SPクローズにあたりSPもPC表示にする
                        end
    else
      :desktop
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session # @author hasumi
end
