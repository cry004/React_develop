require 'test_helper'
class API::V5::LearningProgressesTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.first
      @current_student.update(classroom_id: 1)
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  %w(c k).each do |school|
    describe 'GET /api/v5/learning_progresses' do
      subject { get '/api/v5/learning_progresses' }

      let(:response_data) { Oj.load(last_response.body)['data'] }

      describe 'when student only has videos belonging to some textbooks' do
        before do
          @current_student.update(school: school)
          subject
        end

        describe "when student.school is #{school}" do
          it 'returns status ok' do
            assert last_response.ok?
          end

          it 'should have student node' do
            assert response_data['student']
          end

          it 'should have student level node' do
            assert_equal response_data['student']['level'], 20
          end

          it 'should have level_progress node' do
            assert_equal response_data['level_progress'], 28.5714285714286
          end

          it 'should have learning_time node' do
            assert_equal response_data['learning_time'], { 'hours' => 2, 'minutes' => 26 }
          end

          it 'should have subjects node' do
            assert_equal response_data['subjects'].size, 5
          end

          it 'should have subjects order' do
            assert_equal response_data['subjects'].map { |subject| subject['subject_name']['key'] }, 
                         API::V5::LearningProgressesHelpers::SUBJECTS_ORDER
          end

          it 'should have last_learning_subjects node' do
            assert response_data['last_learning_subjects']
          end

          it 'should have school node' do
            assert response_data['student']['school']
          end

          it 'should have school_name node' do
            assert response_data['student']['classroom_name']
          end
        end

        describe 'subjects node' do
          it 'has videos count' do
            assert response_data['subjects'].first['total_videos_count']
            assert response_data['subjects'].first['watched_videos_count']
            case school
            when 'c'
              assert_equal response_data['subjects'].first['watched_videos_count'], 21
            when 'k'
              assert_equal response_data['subjects'].first['watched_videos_count'], 0
            end
          end

          it 'has trophies count' do
            assert response_data['subjects'].first['total_trophies_count']
            assert response_data['subjects'].first['completed_trophies_count']
            case school
            when 'c'
              assert_equal response_data['subjects'].first['completed_trophies_count'], 5
            when 'k'
              assert_equal response_data['subjects'].first['completed_trophies_count'], 0
            end
          end
        end

        describe 'last_learning_subjects node' do
          it 'has videos count' do
            assert response_data['last_learning_subjects'].first['total_video_count']
            assert response_data['last_learning_subjects'].first['learned_video_count']
            assert_equal response_data['last_learning_subjects'].first["subject_name"], "数学"
            assert_equal response_data['last_learning_subjects'].first['learned_video_count'], 1
          end

          it 'has trophies count' do
            assert response_data['last_learning_subjects'].first['total_trophies_count']
            assert response_data['last_learning_subjects'].first['completed_trophies_count']
            assert_equal response_data['last_learning_subjects'].first['completed_trophies_count'], 0
          end
        end
      end

      describe 'when student has videos free' do
        before do
          @current_student.update(school: school)
          params = { viewed_time: 600 }
          post "/api/v5/videos/3957/watches", params
          subject
        end

        it 'returns status ok' do
          assert last_response.ok?
        end

        it 'increase learning time' do
          assert_equal response_data['learning_time'], { 'hours' => 2, 'minutes' => 36 }
        end

        it 'does not change last_learning_subjects' do
          assert_equal response_data['last_learning_subjects'].first["subject_name"], "数学"
          assert_equal response_data['last_learning_subjects'].first['learned_video_count'], 1
        end
      end
    end
  end
end
