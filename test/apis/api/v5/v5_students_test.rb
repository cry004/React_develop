require 'test_helper'
class API::V5::StudentsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless name.include?('ログイン') || name.include?('login')
      @current_student = Student.second
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
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

  def schoolbooks_json
    '{ "c1":
       { "english":     { "name": "標準" },
         "mathematics": { "name": "未来へひろがる数学（啓林館）" }
       }
     }'
  end

  def invalid_schoolbooks_json
    '{ "c1":
       { "invalid": { "name": "invalid" },
         "invalid": { "name": "invalid" }
       }
     }'
  end

  describe 'PUT api/v5/students/me' do
    subject { put '/api/v5/students/me', params }

    let(:params)        { { avatar: avatar, nick_name: nick_name } }
    let(:avatar)        { '1' }
    let(:nick_name)     { 'valid' }
    let(:error_message) { Oj.load(last_response.body)['meta']['error_messages'] }

    before { subject }

    describe 'with valid params' do
      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns no error messages' do
        assert_equal true , Oj.load(last_response.body)
      end
    end

    describe 'with invalid params' do
      describe 'with invalid avatar' do
        let(:avatar) { '20' }

        it 'returns status 400' do
          assert_equal 400, last_response.status
        end

        it 'returns error messages' do
          message = "#{Student.human_attribute_name(:avatar)}#{I18n.t('errors.messages.inclusion')}"
          assert_equal [message], error_message
        end
      end

      %w(1 あ).each do |name|
        describe 'with too short nickname' do
          let(:nick_name) { name }

          it 'returns status 400' do
            assert_equal 400, last_response.status
          end

          it 'returns error messages' do
            message = "#{Student.human_attribute_name(:nick_name)}#{I18n.t('activerecord.errors.models.student.attributes.nick_name.length', min: 2, max: 16)}"
            assert_equal [message], error_message
          end
        end
      end

      %w(thisis17wordsname これは１７文字のニックネームです。).each do |name|
        describe 'with too long nickname' do
          let(:nick_name) { name }

          it 'returns status 400' do
            assert_equal 400, last_response.status
          end

          it 'returns error messages' do
            message = "#{Student.human_attribute_name(:nick_name)}#{I18n.t('activerecord.errors.models.student.attributes.nick_name.length', min: 2, max: 16)}"
            assert_equal [message], error_message
          end
        end
      end

      %w(エッチング技法 09012345678).each do |name|
        describe 'with ng nickname' do
          let(:nick_name) { name }

          it 'returns status 400' do
            assert_equal 400, last_response.status
          end

          it 'returns error messages' do
            message = I18n.t('activerecord.errors.messages.ng_word', attribute: Student.human_attribute_name(:nick_name))
            assert_equal [message], error_message
          end
        end
      end
    end
  end

  describe 'GET api/v5/students/me' do
    subject { get '/api/v5/students/me' }
    let(:response_data) { Oj.load(last_response.body)['data'] }
    before { subject }

    it 'should return 200' do
      assert last_response.ok?
    end

    it 'should have unread_notification_count node' do
      assert_equal response_data['unread_notifications_count'],
                   @current_student.unread_notification_num
    end

    it 'should have shool_year node' do
      assert_equal response_data['school_year'], @current_student.schoolyear
    end

    it 'should have school_address node' do
      assert_equal response_data['school_address'], @current_student.school_prefecture
    end

    it 'should have available_point node' do
      assert_equal response_data['available_point'], @current_student.available_point
    end

    it 'should have question_point node' do
      assert_equal response_data['question_point'], Product.question_points
    end

    it 'should have purchasable node' do
      assert_equal response_data['purchasable'], @current_student.purchasable?
    end

    it 'should have school node' do
      assert_equal response_data['school'], @current_student.school
    end

    it 'should have current_monthly_point node' do
      assert_equal response_data['current_monthly_point'], @current_student.current_monthly_point
    end

    it 'should have avatar node' do
      assert_equal response_data['avatar'], @current_student.avatar
    end

    it 'should have nick_name node' do
      assert_equal response_data['nick_name'], @current_student.nick_name
    end

    it 'should have full_name node' do
      assert_equal response_data['full_name'], @current_student.full_name
    end

    it 'should have unread_news_count node' do
      assert_equal response_data['unread_news_count'], @current_student.unread_news_num
    end

    it 'should have is_internal_member node' do
      assert_equal response_data['is_internal_member'], @current_student.fist?
    end

    it 'should have is_new_user node' do
      assert_equal response_data['is_new_user'], @current_student.new_user?
    end
  end

  describe 'GET /api/v5/students/me/schoolbooks' do
    subject { get '/api/v5/students/me/schoolbooks' }
    before { subject }

    let(:meta) { Oj.load(last_response.body)['meta'] }
    let(:schoolyears) { Oj.load(last_response.body)['data']['schoolyears'] }

    it 'returns status code 200' do
      assert_equal 200, meta['code']
    end

    it 'has three years' do
      assert_equal 3, schoolyears.count
    end

    it 'has subjects node' do
      assert schoolyears[0]['subjects']
      assert schoolyears[0]['subjects'][0]['course_name']
      assert schoolyears[0]['subjects'][0]['key']
      assert schoolyears[0]['subjects'][0]['name']
      assert schoolyears[0]['subjects'][0]['schoolbooks']
    end
  end

  describe 'PUT api/v5/students/me/schoolbook_dialogs' do
    subject { put '/api/v5/students/me/schoolbook_dialogs' }

    let(:response_data) { Oj.load(last_response.body) }

    describe 'with valid params' do
      it 'returns status 200' do
        subject
        assert_equal 200, last_response.status
      end

      it 'returns no error messages' do
        subject
        assert response_data
      end
    end
  end

  describe 'PUT /api/v5/students/me/schoolbooks' do
    subject { put '/api/v5/students/me/schoolbooks', params }

    before { subject }

    let(:meta) { Oj.load(last_response.body)['meta'] }

    describe 'valid params' do
      let(:params) { { schoolbooks: schoolbooks_json } }

      it 'returns status code 201' do
        assert_equal 201, meta['code']
      end

      it 'returns trophies_count by 2' do
        assert_equal 2, @current_student.trophies_count
      end
    end

    describe 'invalid params' do
      describe 'schoolbooks empty' do
        let(:params) { { schoolbooks: '{"c1": {}}' } }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end
      end

      describe 'invalid schoolbooks json' do
        let(:params) { { schoolbooks: invalid_schoolbooks_json } }

        it 'returns status code 400' do
          assert_equal 400, meta['code']
        end
      end

      describe 'not is json' do
        let(:params) { { schoolbooks: 'invalid' } }

        it 'returns status code 400' do
          assert_equal 500, meta['code']
        end
      end
    end
  end

  describe 'PUT /api/v5/students/me/schools' do
    subject { put '/api/v5/students/me/schools', params }
    before { subject }

    let(:response_data) { Oj.load(last_response.body) }

    describe 'with valid params' do
      let(:params) { { school: 'k' } }

      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns no error messages' do
        assert response_data
      end
    end

    describe 'with invalid params' do
      let(:params) { { school: 's' } }

      it 'returns status 400' do
        assert_equal 400, last_response.status
      end
    end
  end

  describe 'GET /api/v5/students/me/privacy_settings' do
    subject { get '/api/v5/students/me/privacy_settings' }
    before { subject }

    it 'returns status 200' do
      assert_equal 200, last_response.status
    end

    it 'has private_flag' do
      if @current_student.private_flag
        assert Oj.load(last_response.body)['data']['private_flag'] == true
      else
        assert Oj.load(last_response.body)['data']['private_flag'] == false
      end
    end
  end

  describe 'PUT /api/v5/students/me/privacy_settings' do
    subject { put '/api/v5/students/me/privacy_settings', params }
    before { subject }

    describe 'with valid params' do
      let(:params) { { private_flag: true } }
      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'private_flag returns true' do
        assert_equal true, @current_student.private_flag
      end
    end

    describe 'with invalid params' do
      let(:params) { { private_flag: '' } }
      it 'returns status 400' do
        assert_equal 400, last_response.status
      end
    end
  end
end
