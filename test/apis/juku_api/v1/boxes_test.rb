require 'test_helper'

class JukuAPI::V1::BoxTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include JukuAPI::Root.helpers

  def app
    Rails.application
  end

  def setup
    super
    @current_chief = Chief.take
    create_access_token
    update_access_token
    header 'Content-Type',    'application/json'
    header 'X-Authorization', "Bearer #{@access_token}"
  end

  let(:response_data) { Oj.load(last_response.body) }

  describe 'GET /juku/v1/boxes' do
    after { VCR.eject_cassette }

    subject { get '/juku/v1/boxes', params }

    let(:params) do
      { classroom_id: classroom_id,
        start_date:   start_date,
        end_date:     end_date }
    end

    describe 'positive testing' do
      let(:classroom_id) { '3211' }

      describe 'with classroom_id, start_date, end_date' do
        before { VCR.insert_cassette 'get_boxes_with_all_params' }

        let(:start_date)   { '2016-06-01' }
        let(:end_date)     { '2016-06-01' }

        it 'returns HTTP 200 status' do
          subject
          assert_equal 200, last_response.status
        end
      end
    end
  end
end
