require 'test_helper'

class Students::WelcomeControllerTest < ActionController::TestCase
  test "should redirect to root and delete access token cookie" do
    cookies[:access_token] = 'foo'
    get :reset_session
    assert_redirected_to :root
    assert_nil cookies[:access_token]
  end
end
