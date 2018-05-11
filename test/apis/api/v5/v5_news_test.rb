require 'test_helper'

class API::V5::NewsTest < ActiveSupport::TestCase
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

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/news' do
    subject { get '/api/v5/news', params }
    before { subject }

    let(:data)   { Oj.load(last_response.body)['data']['news'] }

    describe 'without pagination params' do
      let(:params) { {} }
      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns valid nodes' do
        assert_equal %w(id title date unread), data.flat_map(&:keys).uniq
      end
    end

    describe 'with pagination params' do
      describe 'normal page' do
        let(:params) { { max_id: 3, per_page: 20 } }

        it 'returns items less than per_page or equal' do
          assert data.size <= params[:per_page]
        end
      end
      describe 'last page' do
        let(:params) { { max_id: 2, per_page: 20 } }

        it 'returns items less than per_page or equal' do
          assert data.size.zero?
        end
      end
    end
  end

  describe 'GET /api/v5/news/:id' do
    subject { get "/api/v5/news/#{id}" }
    before { subject }

    let(:data) { Oj.load(last_response.body)['data'] }

    describe 'with valid id' do
      let(:id) { 2 } # from fixtures

      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns valid nodes' do
        assert_equal %w(id title content date image_url), data.keys
      end
    end

    describe 'with invalid id' do
      let(:id) { News.last.id.succ }

      it 'returns status 404' do
        assert_equal 404, last_response.status
      end
    end
  end

  describe 'PUT /api/v5/news/:id/reads' do
    subject { put "/api/v5/news/#{id}/reads" }
    before { subject }

    describe 'with unread news' do
      let(:id) { 2 } # from fixtures

      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'change news.unread to false' do
        assert_equal false, NewsStudent.find(2).unread
      end
    end

    describe 'with not exist news id' do
      let(:id) { News.last.id.succ }

      it 'returns status 404' do
        assert_equal 404, last_response.status
      end
    end
  end
end
