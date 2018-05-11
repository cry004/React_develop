require 'test_helper'

class API::V5::DevicesTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  MOBILE_HTTP_USER_AGENT = { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_0_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13A404 Safari/601.1' }

  def app
    Rails.application
  end

  def setup
    super
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  describe 'POST api/v5/devices' do
    subject { post '/api/v5/devices', params, MOBILE_HTTP_USER_AGENT }

    describe 'with valid params' do
      let(:params) do
        { token: 'abc1234' }
      end

      it 'returns status 201' do
        subject
        assert_equal 201, last_response.status
      end
    end

    describe 'with invalid params' do
      let(:params) do
        { token_invalid: 'abc123' }
      end

      it 'returns status 400' do
        subject
        assert_equal 400, last_response.status
      end
    end
  end

  describe 'DELETE api/v5/devices' do
    subject { delete '/api/v5/devices', params, MOBILE_HTTP_USER_AGENT }

    before do
      Device.skip_callback(:save, :before)
      Device.create!(pushable_type: 'Student', pushable_id: 2, token: 'token', os: 'ios')
      Device.set_callback(:save, :before)
      subject
    end

    describe 'with valid params' do
      let(:params) { { token: 'token' } }

      it 'returns status 204' do
        assert_equal 204, last_response.status
      end
    end

    describe 'with invalid params' do
      let(:params) { { token: '123' } }

      it 'returns status 404' do
        assert_equal 404, last_response.status
      end
    end
  end
end
