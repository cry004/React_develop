require 'test_helper'
class API::V5::CoursesTest < ActiveSupport::TestCase
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

  describe 'GET /api/v5/courses' do
    subject { get '/api/v5/courses', params }

    let(:meta) { Oj.load(last_response.body)['meta'] }
    let(:data) { Oj.load(last_response.body)['data'] }

    before { subject }
    describe 'no params grade' do
      let(:params) { { course_name: 'science' } }

      describe 'when valid course_name params' do
        it 'returns status code 200' do
          assert_equal 200, meta['code']
        end

        it 'has general data' do
          assert data['course_name']
          assert data['trophies_progress']
          assert data['videos_progress']
          assert data['grade']
        end

        it 'returns 2 grades' do
          assert_equal 2, data['grade'].count
        end
      end

      describe 'when invalid course_name params' do
        let(:params) { { course_name: 'invalid_name' } }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end

        it 'returns error type invalid params' do
          assert_equal 'ParameterValidationErrors', meta['error_type']
        end
      end
    end

    [{ grade: 'c' }, { grade: 'k' }]
    .each do |test_case|
      describe "with params grade #{test_case[:grade]}" do

        describe 'when valid grade params' do
          let(:params) { { course_name: 'science', grade: test_case[:grade].to_s } }

          it "returns grade is #{test_case[:grade]}" do
            assert_equal test_case[:grade], data['grade'][0]['grade']
          end

          it 'has data' do
            assert data['grade'][0]['grade']
            assert data['grade'][0]['subjects']
            assert data['grade'][0]['subjects'][0]['title']
            assert data['grade'][0]['subjects'][0]['subject_key']
            assert data['grade'][0]['subjects'][0]['schoolyear']
            assert data['grade'][0]['subjects'][0]['trophies_progress']
            assert data['grade'][0]['subjects'][0]['videos_progress']
          end
        end

        describe 'when invalid grade params' do
          let(:params) { { course_name: 'science', grade: 'invalid' } }

          it 'returns status code 400' do
            assert_equal 400, meta['code']
          end

          it 'returns error type invalid params' do
            assert_equal 'ParameterValidationErrors', meta['error_type']
          end
        end
      end
    end
  end
end
