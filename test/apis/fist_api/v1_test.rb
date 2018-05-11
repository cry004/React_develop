require 'test_helper'

class FistAPI::V1Test < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def setup
    super
    ENV['FIST_BASIC_AUTH_USER']     = 'test_user'
    ENV['FIST_BASIC_AUTH_PASSWORD'] = 'test_user'
    basic_authorize 'test_user', 'test_user'
    # これがないとPG::UniqueViolation: ERRORとなる。
    ActiveRecord::Base.connection.execute(
      "ALTER SEQUENCE parents_id_seq RESTART WITH #{Parent.last.id + 1};
       ALTER SEQUENCE students_id_seq RESTART WITH #{Student.last.id + 1};"
    )
  end

  describe 'POST fist_api/v1/users' do
    subject { post 'fist_api/v1/users', params }

    before { subject }

    let(:params) do
      {
        KIYKSH_CD:        '0000000000000',
        RNRKSK_MAIL:      email,
        KIYKSH_PSWRD:     'testtest',
        KIYKSH_SMI:       '親　親',
        KIYKSH_KNSMI:     'オヤ　オヤ',
        KIYKSH_POST_NO:   '4670064',
        KIYKSH_ADR_CD:    '00000000000',
        KIYKSH_ADR1:      '1-1',
        KIYKSH_ADR2:      'マンション',
        KIYKSH_TEL_NO:    '08011112222',
        SIT_CD:           '12345678901',
        SIT_PSWRD:        'testtesuo',
        USER_NAME:        username,
        SIT_SMI:          '手酢戸　輝巣雄',
        SIT_KNSMI:        'テスト　テスオ',
        SEX_KBN:          '02',
        BIRTH_DATE_YMD:   '19980213',
        GKNN_CD:          '99',
        GKK_CD:           '11111111',
        INS_DT:           '2014/07/03',
        SIT_STS_KBN:      '02',
        IT_LOGIN_KH_FLAG: '1',
        TMP_CD:           '0001',
        GYTI_KBN:         '01',
        private_flag:     false
      }
    end

    let(:response_data) { Oj.load(last_response.body) }

    describe 'with valid params' do
      describe 'when the parent record does not exist' do
        let(:email)    { 'test@examle.com' }
        let(:username) { 'testtesuo' }

        it 'returns HTTP 201 status' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            assert_equal 201, last_response.status
          end
        end

        it 'creates the student record' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            student = Student.find_by(username: params[:USER_NAME])
            assert_equal params[:TMP_CD],   student.classroom.tmp_cd
            assert_equal params[:GYTI_KBN], student.classroom.type
            assert_equal false,             student.private_flag
          end
        end
      end

      describe 'when the parent record exists' do
        let(:email)    { parent.email }
        let(:username) { student.username }
        let(:parent)   { student.parent }
        let(:student)  { Student.take }

        it 'returns HTTP 201 status' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            assert_equal 201, last_response.status
          end
        end

        it 'updates the parent record' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            parent.reload
            names = params[:KIYKSH_SMI].split('　')
            kanas = params[:KIYKSH_KNSMI].split('　')
            assert_equal params[:KIYKSH_CD], parent.kiyksh_cd
            assert_equal names[0],           parent.family_name
            assert_equal names[1],           parent.first_name
            assert_equal kanas[0],           parent.family_name_kana
            assert_equal kanas[1],           parent.first_name_kana
          end
        end

        it 'updates the student record' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            student.reload
            names = params[:SIT_SMI].split('　')
            kanas = params[:SIT_KNSMI].split('　')
            assert_equal params[:SIT_CD],         student.sit_cd
            assert_equal params[:GKNN_CD],        student.gknn_cd
            assert_equal 'fist',                  student.current_member_type
            assert_equal params[:INS_DT],         student.ins_dt.strftime('%Y/%m/%d')
            assert_equal names[0],                student.family_name
            assert_equal names[1],                student.first_name
            assert_equal kanas[0],                student.family_name_kana
            assert_equal kanas[1],                student.first_name_kana
            assert_equal params[:BIRTH_DATE_YMD], student.birthday.strftime('%Y%m%d')
            assert_equal params[:TMP_CD],         student.classroom.tmp_cd
            assert_equal params[:GYTI_KBN],       student.classroom.type
            assert_equal false,                   student.private_flag
          end
        end

        it 'does not update the student password' do
          Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
            student.reload
            assert_not student.valid_password?(params[:SIT_PSWRD].downcase)
          end
        end
      end
    end

    describe 'with invalid params' do
      let(:email)    { 'test@examle.com' }
      let(:username) { 'user' }
      it 'returns HTTP 400 status with error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ActiveRecord::RecordInvalid', response_data.dig('meta', 'error_type')
          assert_includes response_data.dig('meta', 'error_message').keys, 'username'
        end
      end
    end
  end

  describe 'PUT /fist_api/v1/users' do
    subject { put '/fist_api/v1/users', params }

    before { subject }

    let(:response_data) { Oj.load(last_response.body) }
    let(:parent) { Parent.find(5) }

    describe 'with valid params' do
      let(:email) { 'new.email@example.com' }
      let(:params) do
        { KIYKSH_CD:   parent.kiyksh_cd,
          RNRKSK_MAIL: email }
      end
      it 'returns HTTP 201 status' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert 201, last_response.status
        end
      end
      it 'updates the parent record' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          parent.reload
          assert_equal email, parent.email
        end
      end
    end

    describe 'with invalid params' do
      let(:params) { { invalid: true } }
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ValidationErrors', response_data['meta']['error_type']
        end
      end
    end

    describe 'with invalid values' do
      let(:email) { 'example@example.com' } # duplicated email address
      let(:params) do
        { KIYKSH_CD:   parent.kiyksh_cd,
          RNRKSK_MAIL: email }
      end
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ActiveRecord::RecordInvalid', response_data['meta']['error_type']
          assert_includes response_data['meta']['error_message'].keys, 'email'
        end
      end
    end
  end

  describe 'PUT /fist_api/v1/parents/passwords' do
    subject { put '/fist_api/v1/parents/passwords', params }

    before { subject }

    let(:response_data) { Oj.load(last_response.body) }
    let(:parent) { Parent.find(5) }

    describe 'with valid params' do
      let(:password) { 'Password123' }
      let(:params) do
        { KIYKSH_CD:    parent.kiyksh_cd,
          KIYKSH_PSWRD: password }
      end
      it 'returns HTTP 201 status' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert 201, last_response.status
        end
      end
      it 'updates the parent record' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          parent.reload
          assert parent.valid_password?(password)
        end
      end
    end

    describe 'with invalid params' do
      let(:params) { { invalid: true } }
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ValidationErrors', response_data['meta']['error_type']
        end
      end
    end

    describe 'with invalid values' do
      let(:password) { 'Password123' }
      let(:params) do
        { KIYKSH_CD:    'invalid',
          KIYKSH_PSWRD: password }
      end
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 404, last_response.status
          assert_equal 'ActiveRecord::RecordNotFound', response_data['meta']['error_type']
        end
      end
    end
  end

  describe 'PUT /fist_api/v1/students/passwords' do
    subject { put '/fist_api/v1/students/passwords', params }

    before { subject }

    let(:response_data) { Oj.load(last_response.body) }
    let(:student) { Student.find(1) }

    describe 'with valid params' do
      let(:password) { 'Password123' }
      let(:params) do
        { SIT_CD:    student.sit_cd,
          SIT_PSWRD: password }
      end
      it 'returns HTTP 201 status' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert 201, last_response.status
        end
      end
      it 'updates the parent record' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          student.reload
          assert student.valid_password?(password)
        end
      end
    end

    describe 'with invalid params' do
      let(:params) { { invalid: true } }
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ValidationErrors', response_data['meta']['error_type']
        end
      end
    end

    describe 'with invalid values' do
      let(:password) { 'Password123' }
      let(:params) do
        { SIT_CD:    'invalid',
          SIT_PSWRD: password }
      end
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 404, last_response.status
          assert_equal 'ActiveRecord::RecordNotFound', response_data['meta']['error_type']
        end
      end
    end
  end

  describe 'PUT fist_api/v1/classrooms/:TMP_CD' do
    subject { put "fist_api/v1/classrooms/#{tmp_cd}", params }

    before { subject }

    let(:response_data) { Oj.load(last_response.body) }

    describe 'with valid params' do
      let(:tmp_cd) { '0001' }
      let(:params) do
        { TMP_NM:       '松江駅前個別',
          GYTI_KBN:     '01',
          TMP_TDFKN_CD: '32',
          TMP_STS:      '1' }
      end
      it 'returns HTTP 201 status' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert 201, last_response.status
        end
      end
    end

    describe 'with invalid params' do
      let(:tmp_cd) { '0001' }
      let(:params) { { invalid: true } }
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ValidationErrors', response_data['meta']['error_type']
        end
      end
    end

    describe 'with invalid values' do
      let(:tmp_cd) { '00010' }
      let(:params) do
        { TMP_NM:       '松江駅前個別',
          GYTI_KBN:     '01',
          TMP_TDFKN_CD: '32',
          TMP_STS:      '1' }
      end
      it 'returns error messages' do
        Rails.stub(:env, ActiveSupport::StringInquirer.new('teacher_production')) do
          assert_equal 400, last_response.status
          assert_equal 'ActiveRecord::RecordInvalid', response_data['meta']['error_type']
          assert_includes response_data['meta']['error_message'].keys, 'tmp_cd'
        end
      end
    end
  end
end
