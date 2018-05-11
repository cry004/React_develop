require 'test_helper'
class API::V5::JukuLearningsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.first
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  def teardown
    super
  end

  describe 'GET /api/v5/juku_learnings/currents' do
    subject { get '/api/v5/juku_learnings/currents' }
    let(:data) { Oj.load(last_response.body)['data'] }
    before {subject}

    it 'returns 200 status' do
      assert last_response.ok?
    end

    it 'has learnings node' do
      assert data['learnings']
    end

    it 'has total node' do
      assert data['total']
    end

    it 'has archive_existence_flag node' do
      assert !data['archive_existence_flag'].nil?
    end
  end

  describe 'GET  /api/v5/juku_learnings/archives' do
    subject { get '/api/v5/juku_learnings/archives', params }
    let(:data) { Oj.load(last_response.body)['data'] }
    before {subject}

    describe 'without params' do
      let(:params) { {} }

      it 'returns 200 status' do
        assert last_response.ok?
      end

      it 'has learnings node' do
        assert data['learnings']
      end
    end

    describe 'with pagination params' do
      let(:params) { { page: page, per_page: per_page } }

      describe 'with pagination per_page params 10' do
        let(:page)     { 1 }
        let(:per_page) { 10 }

        it 'returns less than 10 learnings or equal' do
          assert data['learnings'].size <= per_page
        end
      end

      describe 'with pagination page params 2' do
        let(:page) { 2 }
        let(:per_page) { 10 }

        it 'returns per_page count learnings' do
          assert_equal data['learnings'].size, 0
        end
      end
    end
  end
end
