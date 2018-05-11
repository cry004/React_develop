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

  def expect_status(status)
    subject
    assert_equal status, last_response.status
  end

  let(:response_data) { Oj.load(last_response.body) }

  describe 'GET /juku/v1/sub_units' do
    subject { get '/juku/v1/sub_units', params }

    sub_subject_keys = %w(c1_english_regular
                          c_sociology_geography
                          c_mathematics_standard
                          c_civics_high-level
                          k_english_grammar
                          k_mathematics_3
                          k_physics_basis
                          k_biology
                          k_world_history)
    sub_subject_keys.each do |sub_subject_key|
      describe "sub_subject_key=#{sub_subject_key}" do
        let(:params) { { sub_subject_key: sub_subject_key } }
        it { expect_status(200) }
      end
    end

    describe 'incorrect params testing' do
      let(:params) { { sub_subject_key: 'incorrect_params' } }
      it { expect_status(500) }
    end

    describe 'other params testing' do
      let(:params) { { other_params: 'other_params' } }
      it { expect_status(400) }
    end

    describe 'without params testing' do
      let(:params) {}
      it { expect_status(400) }
    end

    describe 'more than one params testing' do
      let(:params) { { sub_subject_key: 'c1_english_regular', other_params: 'other_params' } }
      it { expect_status(400) }
    end
  end
end
