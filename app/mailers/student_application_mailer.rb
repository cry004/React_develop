class StudentApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: "トライ 添削指導サービス <noreply@try-it.jp>"
  layout 'student_mailer'
end
