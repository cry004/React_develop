require 'test_helper'
class API::V5::PointRequestsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  # Not done without DBClean
  def teardown
    super
  end

  def cookies
    @cookies ||= {}
  end

  def params
    @params ||= {}
  end

  describe 'POST /api/v5/point_request' do
    subject { post '/api/v5/point_requests' }
    it 'returns 201 status' do
      subject
      assert_equal 201, last_response.status
    end
  end
end
