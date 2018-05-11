require 'test_helper'

class API::V5::TeacherRecommendationsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu.
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.first
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
    @logger = TestLogger.new
    Rails.logger = @logger # Capture log output.
    Rails.logger.formatter = SimpleLogFommater.new # Only message to log output
  end

  def params
    @params ||= {}
  end

  def assert_meta_nodes(meta)
    assert meta['code']
    assert meta['access_token']
    assert meta['player_type']
  end

  def teacher_recommendations
    @current_student.teacher_recommendations
  end

  def not_exist_teacher_recommendation_id
    teacher_recommendations.last.id + 1
  end

  def teacher_recommendation_id_unread
    teacher_recommendations.where(unread: true).first.id
  end

  def teacher_recommendation_id_readed
    recommendation = teacher_recommendations.first
    recommendation.update(unread: false)
    recommendation.id
  end

  def exist_teacher_recommendation_id
    teacher_recommendations.first.id
  end

  let(:meta) { Oj.load(last_response.body)['meta'] }
  let(:data) { Oj.load(last_response.body)['data'] }

  describe 'GET /api/v5/teacher_recommendations' do
    subject { get '/api/v5/teacher_recommendations', params }

    describe 'when do not have params' do
      it 'returns 200' do
        subject
        assert last_response.ok?
      end

      it 'returns default json' do
        subject
        assert_meta_nodes meta
      end
    end

    describe 'with pagination params' do
      [{ title: 'with first page',                     value: { page: 1,     per_page: 20 } },
       { title: 'with exist page and random per_page', value: { page: 3,     per_page: 15 } },
       { title: 'page request more than exist page',   value: { page: 99999, per_page: 20 } }]
      .each do |test_case|
        describe test_case[:title] do
          let(:params) {test_case[:value]}
          before { subject }
          it 'returns 200' do
            assert last_response.ok?
          end

          it 'returns default json' do
            assert_meta_nodes meta
          end

          it 'returns items less than per_page or equal' do
            assert data['recommendations'].count <= params[:per_page]
          end
        end
      end

      describe 'when student has no teacher_recommendations' do
        before do
          @current_student = Student.where(state: 'active').last
          create_access_token
          header 'Authorization', "Bearer #{@access_token}"
        end

        it 'returns 200' do
          subject
          assert last_response.ok?
        end

        it 'returns default json' do
          subject
          assert_meta_nodes meta
        end
      end
    end
  end

  describe 'PUT /api/v5/teacher_recommendations/:id/reads' do
    subject { put "/api/v5/teacher_recommendations/#{id}/reads" }

    [{ title: 'when unread is false',        id: 'teacher_recommendation_id_readed',    code: 204 },
     { title: 'when not exist id recommend', id: 'not_exist_teacher_recommendation_id', code: 404 }]
    .each do |test_case|
      describe test_case[:title] do
        let(:id) { send(test_case[:id]) }

        it "returns status code #{test_case[:code]}" do
          subject
          assert_equal test_case[:code], meta['code']
        end
      end
    end

    describe 'when unread is true' do
      let(:id) { teacher_recommendation_id_unread }
      it 'returns status 200' do
        subject
        assert_equal 200, last_response.status
      end
    end
  end

  describe 'GET /api/v5/teacher_recommendations/:id' do
    subject { get "/api/v5/teacher_recommendations/#{id}", params }

    let(:meta) { Oj.load(last_response.body)['meta'] }
    let(:data) { Oj.load(last_response.body)['data'] }

    describe 'when exist teacher recommendation' do
      let(:id) { exist_teacher_recommendation_id }
      test_cases = [
        { title: 'first page',     page: 1,   per_page: 10 },
        { title: 'random page',    page: 3,   per_page: 4 },
        { title: 'page too large', page: 999, per_page: 10 }
      ]

      test_cases.each do |test_case|
        describe test_case[:title] do
          it 'returns status code 200' do
            subject
            assert_equal 200, meta['code']
          end

          it 'returns data necessary' do
            subject
            assert(data['teacher_name'])
            assert(data['date'])
            assert(data['message'])
            assert(data['recommended_videos'])
          end
        end
      end
    end

    describe 'when not exist teacher recommendation' do
      let(:id) { not_exist_teacher_recommendation_id }

      it 'returns status code 404' do
        subject
        assert_equal 404, meta['code']
      end

      it 'returns error RecordNotFound' do
        subject
        assert_equal 'ActiveRecord::RecordNotFound', meta['error_type']
      end
    end
  end
end
