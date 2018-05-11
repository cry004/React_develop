class TeacherAccountsMailer < StudentApplicationMailer
  add_template_helper(ApplicationHelper)

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.teacher_accounts_mailer.registration_confirmation.subject
  #
  def registration_confirmation(teacher_account)
    @recipient = teacher_account
    @gate_path = '/admin'
    bcc = Rails.env.teacher_production? ? ['hayashi@elephant-academy.co.jp', 'matsukawa@elephant-academy.co.jp'] : nil
    mail subject: 'トライ 添削指導者登録完了のお知らせ', to: @recipient.email_with_name, bcc: bcc
  end

  def reset_password_instructions(teacher_account)
    @recipient = teacher_account
    @token_url = edit_admin_password_reset_url(teacher_account.password_reset_token)
    bcc = Rails.env.teacher_production? ? ['hayashi@elephant-academy.co.jp', 'matsukawa@elephant-academy.co.jp'] : nil
    mail subject: 'パスワード再設定のお知らせ', to: @recipient.email_with_name, bcc: bcc
   end
end
