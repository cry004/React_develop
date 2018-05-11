# frozen_string_literal: true

require 'test_helper'

# FIXME: remove me! https://rdm.try-it.jp/issues/4714
class API::V3Test < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  describe 'GET /api/v3/utility/gknn_cds' do
    subject { get '/api/v3/utility/gknn_cds' }

    let(:response_data) { Oj.load(last_response.body)['data'] }

    it 'returns valid response' do
      subject
      assert last_response.ok?
      assert response_data.all? { |node| node['code'] && node['name'] }
    end
  end

  describe 'GET /api/v3/utility/school_names' do
    subject { get '/api/v3/utility/school_names', params }

    let(:response_data) { Oj.load(last_response.body)['data'] }

    let(:params) do
      { term:            term,
        prefecture_code: prefecture_code,
        gknn_cd:         gknn_cd }
    end

    let(:term)            { 'ぴ' }
    let(:prefecture_code) { 1 }
    let(:gknn_cd)         { '21' }

    it 'returns valid response' do
      subject
      assert last_response.ok?
      response_data.all? do |school_name|
        assert_instance_of String, school_name
      end
    end
  end
end
