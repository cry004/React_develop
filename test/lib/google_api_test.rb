require 'test_helper'

class GoogleApiTest < ActiveSupport::TestCase
  after { VCR.eject_cassette }

  before do
    VCR.configure do |config|
      config.default_cassette_options = { match_requests_on: %i(method uri) }
    end
  end

  describe 'Base' do
    before { VCR.insert_cassette 'google_api_base_authentication' }

    subject { GoogleApi::Base.new }
    it 'can initialize' do
      instance = subject

      assert_equal(GoogleApi::Base, instance.class)

      client = instance.client
      assert_equal(Google::APIClient, client.class)
    end
  end

  describe 'Calendar' do
    describe '#initialize' do
      before { VCR.insert_cassette 'google_api_calendar_initialize' }
      subject { GoogleApi::Calendar.new }

      it 'can initialize' do
        instance = subject

        assert_equal(GoogleApi::Calendar, instance.class)

        client = instance.client
        assert_equal(Google::APIClient, client.class)
        assert_equal(Google::APIClient::API, instance.service.class)
        assert_equal('ja', instance.lang)
        assert_equal('japanese', instance.country)
        assert_equal(['https://www.googleapis.com/auth/calendar.readonly'],
                     client.authorization.scope)
      end
    end

    describe '#holidays' do
      before { VCR.insert_cassette 'google_api_calendar_holidays' }
      subject do
        GoogleApi::Calendar.new.holidays(start_date: start_date,
                                         end_date: end_date)
      end
      let(:start_date) { '2014-04-1' }
      let(:end_date)   { '2018-04-1' }

      it 'should return holidays array' do
        res = subject

        assert(res.all? { |item| item.key?(:month) && item.key?(:holidays) })
      end
    end
  end
end
