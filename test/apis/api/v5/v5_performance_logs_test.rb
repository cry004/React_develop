require 'test_helper'

class API::V5::PerformanceLogsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu.
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
    @logger = TestLogger.new
    Rails.logger = @logger # Capture log output.
    Rails.logger.formatter = SimpleLogFommater.new # Only message to log output
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

  describe 'POST api/v5/performance_logs' do
    subject { post '/api/v5/performance_logs', params }

    describe 'with valid params' do
      let(:params) do
        { results: [process_name: 'foo', duration: 300] }
      end

      it 'returns status 201' do
        subject
        assert_equal 201, last_response.status
      end

      it 'creates valid logs' do
        subject
        log = @logger.messages_to_hash
        assert_equal 'PerformanceLog',   log['eventName']
        assert_equal [{ 'foo' => 300 }], log['eventData']['durations']
      end
    end

    describe 'with invalid params' do
      tests = [
        { title: 'invalid type of params', params: { results: [process_name: 'foo', duration: 'bar'] } },
        { title: 'invalid key',            params: { results: [foo: 'foo', duration: 300] } }
      ]
      tests.each do |test|
        describe test[:title] do
          let(:params) do
            test[:params]
          end

          it 'returns status 400' do
            subject
            assert_equal 400, last_response.status
          end
        end
      end
    end
  end
end
