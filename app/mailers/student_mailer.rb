class StudentMailer < StudentApplicationMailer
  layout "point_request_mailer", only: [:credit_failure]

  def credit_failure(student)
    @student = student
    @recipient = student.parent
    @gate_url = Settings.hostname.parent + "/creditcard"
    mail(
      to: @recipient.email,
      bcc: Settings.mailing_list_for_developers,
      subject: "月々の上限設定額が決済できませんでした"
    )
  end
end
