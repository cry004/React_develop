require 'test_helper'
class API::V5::LoginTest < ActiveSupport::TestCase
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

  describe 'POST api/v5/login' do
    subject { post '/api/v5/login', { studentId: user_id, password: password } }
    let(:response_data) { Oj.load(last_response.body) }
    let(:user_id) { 'test0001' }
    let(:password) { 'test0001' }

    it 'should have valid node' do
      subject
      assert_equal true, response_data['data']['first_login']
    end

    describe 'when right pw and id' do
      let(:user_id) { 'test0001' }
      let(:password) { 'test0001' }

      it 'return valid node' do
        subject
        meta_node = response_data['meta']
        data_node = response_data['data']

        assert meta_node['access_token']
        assert meta_node['code']
        assert meta_node['player_type']
      end
    end

    describe 'when wrong pw and id' do
      let(:user_id) { 'wrong' }
      let(:password) { 'wroing' }

      it 'return valid node' do
        subject
        meta_node = response_data['meta']
        data_node = response_data['data']

        assert meta_node['error_type']
        assert meta_node['code']
        assert meta_node['error_messages']
        assert_nil data_node
      end
    end

    describe 'when wrong params' do
      subject { post '/api/v5/login', { user_id_wrong: user_id, password_wrong: password } }

      it 'return valid node' do
        subject
        meta_node = response_data['meta']
        data_node = response_data['data']

        assert meta_node['error_type']
        assert meta_node['code']
        assert meta_node['error_messages']
        assert_nil data_node
      end
    end
  end
end
