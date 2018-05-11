class PointRequestMailer < StudentApplicationMailer
  layout "point_request_mailer"

  def settings_monthly_points_at_parent(student)
    set_mail_contens(student)
    @student = student
    @recipient = @student.parent
    mail subject: @subject, to: @recipient.email_with_name
  end

  private

  def set_mail_contens(student)
    if student.settings_point_limits?
      @subject = "生徒から上限追加のリクエストが届いています"
      @gate_url = Settings.hostname.parent + "/pointconfig/edit"
    else
      @subject = "【Try ITよりご連絡】#{student.full_name}さんから通知があります"
      @guidance_url = Settings.hostname.parent + "/guidance"
      @textbook_url = Settings.hostname.parent + "/products"
    end
  end
end
