require 'test_helper'
class API::V5::RankingsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.first
      @current_student.update(classroom_id: 6)
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/rankings/personals' do
    subject { get '/api/v5/rankings/personals', params }
    %w(last_7_days last_month).each do |period_type|
      before { subject }
      let(:response_data) { Oj.load(last_response.body)['data'] }
      let(:params) { { period_type: period_type } }

      it 'returns status ok' do
        assert last_response.ok?
      end

      it 'should have student node' do
        assert response_data['student']['full_name']
        assert response_data['student']['school_year']
        assert response_data['student']['school_address']
        assert response_data['student']['level']
        assert response_data['student']['trophies_count']
        assert response_data['student']['classroom_name']
        assert response_data['student']['classroom_type']
      end

      it 'should have learning_time node' do
        assert response_data['learning_time']
      end

      it 'should have ranking_date node' do
        assert response_data['ranking_date']['start']
        assert response_data['ranking_date']['end']
      end

      it 'should have student_ranking node' do
        assert response_data['current_student_rankings']['prefecture']
        assert response_data['current_student_rankings']['national']
        assert response_data['current_student_rankings']['classroom']
      end

      it 'should have ranking_changes node' do
        assert response_data['ranking_changes']['prefecture']
        assert response_data['ranking_changes']['national']
        assert response_data['ranking_changes']['classroom']
      end

      it 'should have rankings node' do
        assert response_data['rankings']['prefecture']
        assert response_data['rankings']['national']
        assert response_data['rankings']['classroom']
      end

      it 'should have ranking_month node' do
        assert response_data['ranking_month']
      end
    end
  end

  describe 'GET /api/v5/rankings/personal' do
    subject { get '/api/v5/rankings/personal', params }

    %w(prefecture national classroom).each do |ranking_type|
      %w(last_7_days last_month).each do |period_type|
        let(:params) { { ranking_type: ranking_type, period_type: period_type } }
        before { subject }
        let(:response_data) { Oj.load(last_response.body)['data'] }

        it 'returns status ok' do
          assert last_response.ok?
        end

        it 'should have student node' do
          assert response_data['student']['full_name']
          assert response_data['student']['school_year']
          assert response_data['student']['school_address']
          assert response_data['student']['level']
          assert response_data['student']['classroom_type']
        end

        it 'should have learning_time node' do
          assert response_data['learning_time']
        end

        it 'should have current_student_rankings node' do
          assert response_data['current_student_rankings']
        end

        it 'should have ranking_changes node' do
          assert response_data['ranking_changes']
        end

        it 'should have rankings node' do
          assert response_data['rankings']
        end

        it 'should have ranking_month node' do
          assert response_data['ranking_month']
        end
      end
    end
  end

  describe 'GET /api/v5/rankings/classrooms' do
    subject { get '/api/v5/rankings/classrooms' }

    %w(last_7_days last_month).each do |type|
      let(:params) { { period_type: type } }
      before { subject }
      let(:response_data) { Oj.load(last_response.body)['data'] }

      it 'returns status ok' do
        assert last_response.ok?
      end

      it 'should have classroom node' do
        assert response_data['classroom']['id']
        assert response_data['classroom']['color']
        assert response_data['classroom']['name']
        assert response_data['classroom']['type']
        assert response_data['classroom']['prefecture_name']
      end

      it 'should have learning_time node' do
        assert response_data['learning_time']
      end

      it 'should have ranking_date node' do
        assert response_data['ranking_date']['start']
        assert response_data['ranking_date']['end']
      end

      it 'should have classroom_ranking node' do
        assert response_data['current_classroom_rankings']['prefecture']
        assert response_data['current_classroom_rankings']['national']
      end

      it 'should have ranking_changes node' do
        assert response_data['ranking_changes']['prefecture']
        assert response_data['ranking_changes']['national']
      end

      it 'should have rankings node' do
        assert response_data['rankings']['classroom_prefecture']
        assert response_data['rankings']['classroom_national']
        assert response_data['rankings']['schoolhouse_national']
      end
    end
  end

  describe 'GET /api/v5/rankings/classroom' do
    subject { get '/api/v5/rankings/classroom', params }

    before { subject }

    let(:response_data) { Oj.load(last_response.body)['data'] }

    %w(last_7_days last_month).each do |period_type|
      %w(prefecture national).each do |type|
        %w(classroom).each do |classtype|

          describe 'with valid params for classroom' do
            let(:params) { { ranking_type: type, period_type: period_type, classroom_type: classtype } }

            it 'returns status ok' do
              assert last_response.ok?
            end

            it 'should have classroom node' do
              assert response_data['classroom']['id']
              assert response_data['classroom']['color']
              assert response_data['classroom']['name']
              assert response_data['classroom']['type']
              assert response_data['classroom']['prefecture_name']
            end

            it 'should have learning_time node' do
              assert response_data['learning_time']
            end

            it 'should have current_classroom_rankings node' do
              assert response_data['current_classroom_rankings']
            end

            it 'should have ranking_changes node' do
              assert response_data['ranking_changes']
            end

            it 'should have rankings node' do
              assert response_data['rankings']
            end
          end
        end
      end

      %w(national).each do |type|
        %w(schoolhouse).each do |classtype|
          describe 'with valid params for schoolhouse' do
            let(:params) { { ranking_type: type, period_type: period_type, classroom_type: classtype } }

            it 'returns status ok' do
              assert last_response.ok?
            end

            it 'should have classroom node' do
              assert response_data['classroom']['id']
              assert response_data['classroom']['color']
              assert response_data['classroom']['name']
              assert response_data['classroom']['type']
              assert response_data['classroom']['prefecture_name']
            end

            it 'should have learning_time node' do
              assert response_data['learning_time']
            end

            it 'should have current_classroom_rankings node' do
              assert response_data['current_classroom_rankings']
            end

            it 'should have ranking_changes node' do
              assert response_data['ranking_changes']
            end

            it 'should have rankings node' do
              assert response_data['rankings']
            end
          end
        end
      end

      %w(prefecture).each do |type|
        %w(schoolhouse).each do |classtype|
          describe 'with invalid params' do
            let(:params) { { ranking_type: type, period_type: period_type, classroom_type: classtype } }

            it 'returns status 400' do
              assert_equal last_response.status, 400
            end
          end
        end
      end
    end
  end
end
