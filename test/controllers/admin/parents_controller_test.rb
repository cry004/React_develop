require 'test_helper'

class Admin::ParentsControllerTest < ActionController::TestCase
  let(:orig_file) { fixture_file_upload('files/docomo_orig_csv.csv', 'text/comma-separated-values') }
  let(:result_file) { fixture_file_upload('files/docomo_result_csv.csv', 'text/comma-separated-values') }

  test 'should successfully post docomo csv' do
    session[:typus_user_id] = AdminUser.first.id
    post 'docomo_users_csv', file: orig_file
    assert_response :success
  end

  test 'should get correct docomo csv results' do
    session[:typus_user_id] = AdminUser.first.id
    docomo_user = Parent.where(email: 'docomo@example.com').first
    docomo_user.confirmed_at = nil
    docomo_user.save(validate: false)
    post 'docomo_users_csv', file: orig_file
    result_csv_string = result_file.read
    assert_equal(result_csv_string.force_encoding('UTF-8'), response.body, 'returned csv is incorrect')
  end
end
