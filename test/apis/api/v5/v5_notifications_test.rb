require 'test_helper'

class API::V5::NotificationsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.first
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/notifications' do
    subject { get '/api/v5/notifications' }
    before { subject }

    let(:data) { Oj.load(last_response.body)['data']['notifications'] }

    it 'returns status 200' do
      assert_equal 200, last_response.status
    end

    it 'returns valid nodes' do
      assert data.size <= API::V5::NotificationsHelpers::LIMITED_NUMBER
      assert_equal data[0].keys, %w(notification_id notification_type teacher_id title date unread)
    end
  end
end
