require 'test_helper'

class TeacherAccountsMailerTest < ActionMailer::TestCase
  test 'registration_confirmation' do
    mail = TeacherAccountsMailer.registration_confirmation(AdminUser.take)
    assert_equal 'トライ 添削指導者登録完了のお知らせ', mail.subject
    assert_equal ['ml-trygroup-dev@monstar-lab.com'], mail.to
    assert_equal ['noreply@try-it.jp'], mail.from
    assert_match 'このメールには返信できません', mail.body.encoded
  end
end
