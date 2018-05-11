require 'test_helper'
class API::RootHelperTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super
  end

  def teardown
    super
  end

  def cookies
    @cookies ||= {}
  end

  def params
    @params ||= {}
  end

  describe '.authenticate!' do
    subject { get '/api/v5/students/me' }

    let(:response_data) { JSON.parse(last_response.body) }
    let(:response_status) { last_response.status }

    describe 'when X-Authorization Header is not present' do
      it 'should return 401' do
        subject
        assert_equal 401, response_status
      end

      it 'should return valid error json response' do
        subject
        assert_equal 'X-AuthorizationHeaderMissing', response_data['meta']['error_type']
        assert_equal 401, response_data['meta']['code']
        assert_equal ['X-Authorization Header is not provided.'], response_data['meta']['error_messages']
      end
    end

    describe 'when X-Authorization Header is present' do
      describe 'when X-Authorization Header has no Bearer prefix' do
        before do
          header "X-Authorization", "hogehogehogehogehogehoge"
        end

        it 'should have return 401' do
          subject
          assert_equal 401, response_status
        end
        it 'should return valid error json response' do
          subject
          assert_equal 'AccessTokenMissing', response_data['meta']['error_type']
          assert_equal 401, response_data['meta']['code']
          assert_equal ['access_token is not provided.'], response_data['meta']['error_messages']
        end
      end

      describe 'when X-Authorization Header has Bearer prefix' do
        describe 'when student in access_token is not present' do
          before do
            @current_student = Student.find_by(state: 'inactive')
            create_access_token
            header "X-Authorization", "Bearer #{@access_token}"
          end
          it 'should have return 401' do
            subject
            assert_equal 401, response_status
          end
          it 'should return valid error json response' do
            subject
            assert_equal 'StudentNotExistException', response_data['meta']['error_type']
            assert_equal 401, response_data['meta']['code']
            assert_equal ['the student claimed is not exist.'], response_data['meta']['error_messages']
          end
        end

        describe 'when student in access_token is present' do
          before do
            @current_student = Student.find_by(state: 'active')
            create_access_token
            header "X-Authorization", "Bearer #{@access_token}"
          end

          it 'should have return 200' do
            subject
            assert_equal 200, response_status
          end
        end
      end
    end
  end
end
