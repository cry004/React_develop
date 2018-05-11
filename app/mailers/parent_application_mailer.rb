class ParentApplicationMailer < ActionMailer::Base
  helper ApplicationHelper
  default from: "Try IT（トライイット）運営事務局 <info@try-it.jp>"
  layout 'parent_mailer'
end
