require 'test_helper'

class SlackTest < ActiveSupport::TestCase
  after { VCR.eject_cassette }

  describe '.notify_by_webhook' do
    subject { Slack.notify_by_webhook(channel, message_param) }

    let(:message_param) { 'テスト' }

    describe 'with n-development channel' do
      before { VCR.insert_cassette 'slack_notify_by_webhook_development' }

      let(:channel) { 'n-development' }

      it 'should be able to post to channel on slack' do
        assert_equal('200', subject.code)
      end
    end

    describe 'with n-production channel' do
      before { VCR.insert_cassette 'slack_notify_by_webhook_production' }

      let(:channel) { 'n-production' }

      it 'should be able to post to channel on slack' do
        assert_equal('200', subject.code)
      end
    end
  end
end
