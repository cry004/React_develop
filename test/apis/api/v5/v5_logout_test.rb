require 'test_helper'
class API::V5::LogoutTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def teardown
    super
  end

  def params
    @params ||= {}
  end

  describe 'DELETE /api/v5/logout' do
    subject { delete '/api/v5/logout' }
    it 'returns status code 204' do
      subject
      assert_equal 204, last_response.status
    end
  end
end
