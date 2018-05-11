require 'test_helper'

class JukuAPI::V1::ClassroomTest < ActiveSupport::TestCase
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

  describe 'GET classrooms' do
    after { VCR.eject_cassette }

    subject { get '/juku/v1/classrooms', params }

    let(:params) { { prefecture_code: prefecture_code } }

    describe 'positive testing' do
      before { VCR.insert_cassette 'get_classrooms_successfully' }

      let(:prefecture_code) { '01' }

      it 'should return 200' do
        subject
        assert_equal 200, last_response.status
      end
    end

    describe 'negative testing' do
      let(:prefecture_code) { '49' }

      it 'should return 400' do
        subject
        assert_equal 400, last_response.status
      end
    end
  end
end
