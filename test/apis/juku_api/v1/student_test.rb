require 'test_helper'

class JukuAPI::V1::StudentTest < ActiveSupport::TestCase
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

  describe 'GET /juku/v1/classrooms/:id/students' do
    after { VCR.eject_cassette }

    subject { get "/juku/v1/classrooms/#{classroom_id}/students" }

    let(:classroom_id) { '3211' }

    describe 'positive testing' do
      before { VCR.insert_cassette 'get_students' }

      it 'returns HTTP 200 status' do
        subject
        assert_equal 200, last_response.status
      end
    end
  end
end
