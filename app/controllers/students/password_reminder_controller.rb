class Students::PasswordReminderController < Students::ApplicationController
  layout false

  def password
    ua = request.user_agent
    if Woothee.parse(ua)[:category] == :smartphone
      if ua.match('iPad') || ( ua.match('Android') && !ua.match('Mobile') )
        render "password"
      else
        render "password+phone"
      end
    else
      render "password"
    end
  end
end
