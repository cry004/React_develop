require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  def reset_student(current_monthly_point, following_monthly_point, spent_point)
    @student.current_monthly_point = current_monthly_point
    @student.following_monthly_point = following_monthly_point
    @student.spent_point = spent_point
    @student.save!
  end

  def schoolbooks_json
    { 'c1' =>
      { 'english'     => { 'name' => '標準' },
        'mathematics' => { 'name' => '未来へひろがる数学（啓林館）' } } }
  end

  describe '#validations' do
    describe 'with only_fist_member_has_classroom_id' do
      subject { student }

      let(:student) { Student.new(classroom_id: 1) }

      describe 'when student is fist member' do
        it 'allows a classroom_id in validation' do
          student.stub(:fist?, true) do
            assert_empty subject.errors[:classroom_id]
          end
        end
      end

      describe 'when student is not fist member' do
        it 'rejects a bad record in validation' do
          student.stub(:fist?, false) do
            assert subject.invalid?
            assert_includes subject.errors[:classroom_id], I18n.t('errors.messages.invalid')
          end
        end
      end
    end
  end

  describe '#scopes' do
    describe '#news_deliverable' do
      subject { Student.news_deliverable }

      let(:inactive) { Student.first }
      let(:pending)  { Student.second }

      before do
        inactive.update!(state: :inactive)
        pending.update!(state: :pending)
      end

      it 'returns only records with active state' do
        assert subject.pluck(:id).exclude?(inactive.id)
        assert subject.pluck(:id).exclude?(pending.id)
      end
    end
  end

  describe '#create_or_update_from_fist' do
    let(:parent_params) { { email: email } }
    let(:student_params) do
      {
        username: username,
        current_member_type: 'fist',
        original_member_type: 'fist'
      }
    end

    subject do
      Student.create_or_update_from_fist(
        parent_params,
        student_params,
        parent_password,
        student_password
      )
    end

    describe 'with valid params' do
      let(:parent_password) { 'abcd1234' }
      let(:student_password) { 'test0001' }

      let(:existing_email) { 'example@example.com' }
      let(:new_email) { 'new@example.com' }

      let(:existing_username) { 'test0001' }
      let(:new_username) { 'new0001' }

      describe 'create or update parent' do
        let(:username) { new_username }

        describe 'when parent who has the email already exists' do
          let(:email) { existing_email }
          let(:attrs) do
            {
              kiyksh_cd: 'new_kiyksh_cd',
              family_name: 'new_family_name',
              first_name: 'new_first_name',
              family_name_kana: 'ハハ',
              first_name_kana: 'オヤ'
            }
          end

          before { attrs.each { |key, value| parent_params[key] = value } }

          # TODO: Add context for `parent.kiyksh_cd.present? && new_parent_password`
          it "changes parent's attributes" do
            subject
            parent = Parent.find_by(email: existing_email)
            attrs.each { |key, value| assert_equal value, parent[key] }
          end
        end

        describe "when parent who has the email doesn't exist" do
          let(:email) { new_email }

          it "creates a new student" do
            assert_difference 'Parent.count', 1 do
              subject
            end
          end
        end
      end

      describe 'create or update student' do
        let(:email) { existing_email }

        describe 'when student who has the username already exists' do
          let(:username) { existing_username }
          before { attrs.each { |key, value| student_params[key] = value } }

          # TODO: Add classroom
          let(:attrs) do
            {
              sit_cd: 'new_sit_cd',
              gknn_cd: 'new_gknn_cd',
              current_member_type: 'fist',
              ins_dt: DateTime.new(1970, 1, 1),
              family_name: 'new_family_name',
              first_name: 'new_first_name',
              family_name_kana: 'テスト',
              first_name_kana: 'イチロウ',
              birthday: Date.current,
              private_flag: true
            }
          end

          it "changes student's attributes" do
            subject
            student = Student.find_by(username: existing_username)
            attrs.each { |key, value| assert_equal value, student[key] }
          end
        end

        describe "when student who has the username doesn't exist" do
          let(:username) { new_username }

          it "creates a new student" do
            assert_difference 'Student.count', 1 do
              subject
            end
          end
        end

      end
    end
  end

  describe 'ポイント上限のバリデーション' do
    subject { Student.first }
    describe 'current_monthly_point' do
      before { subject.current_monthly_point = 4000 }
      it '0,5000,10000,15000以外のポイント上限には変更できない' do
        assert_raise(ActiveRecord::RecordInvalid) { subject.save! }
      end
    end
    describe 'following_monthly_point' do
      before { subject.following_monthly_point = 5001 }
      it '0,5000,10000,15000以外のポイント上限には変更できない' do
        assert_raise(ActiveRecord::RecordInvalid) { subject.save! }
      end
    end
  end

  describe 'ポイント上限が変更される' do
    subject { @student = Student.first }
    before { subject.reload }

    describe 'ポイント上限を5000から10000に引き上げる' do
      before(:each) do
        reset_student(5000, 5000, 4000)
        @mock = MiniTest::Mock.new.expect(:call, true,
                                          [{ parent: subject.parent,
                                             amount: 5400, student: subject }])
        subject.assign_attributes(following_monthly_point: 10_000)
        ::Credit.stub(:reserve, @mock) { subject.modify_upper_point_limit }
      end
      it '消費税込み5400円の与信処理が走る' do
        @mock.verify.must_equal true
      end
      it '当月ポイント上限が引き上げられる' do
        assert_equal(10_000, subject.current_monthly_point)
      end
      it '消費ポイントは変わらない' do
        assert_equal(4_000, subject.spent_point)
      end
      it '利用可能ポイントは増える' do
        assert_equal(6_000, subject.available_point)
      end
      describe 'その後いちど0に引き下げ、すぐに10000に上げる' do
        before(:each) do
          reset_student(10_000, 0, 4_000)
          subject.assign_attributes following_monthly_point: 0
          subject.modify_upper_point_limit
        end
        it '::Credit.reserveは実行されない' do
          mock = MiniTest::Mock.new.expect(:call, true)
          subject.assign_attributes following_monthly_point: 10_000
          ::Credit.stub(:reserve, mock) { subject.modify_upper_point_limit }
          -> { mock.verify }.must_raise(MockExpectationError)
        end
        it '利用可能ポイントは変わらない' do
          assert_equal 6000, subject.available_point
        end
      end

      describe 'その後いちど0に引き下げ、すぐに15000に上げる' do
        before(:each) do
          reset_student(10_000, 0, 4_000)
          subject.reload
          @mock = MiniTest::Mock.new.expect(:call, true,
                                            [{ parent: subject.parent,
                                               amount: 5400,
                                               student: subject }])
          subject.assign_attributes(following_monthly_point: 15_000)
          ::Credit.stub(:reserve, @mock) { subject.modify_upper_point_limit }
        end
        it '消費税込み5400円の与信処理が走る' do
          @mock.verify.must_equal true
        end
        it '当月ポイント上限が15000になる' do
          assert_equal(15_000, subject.current_monthly_point)
        end
        it '消費ポイントは変わらない' do
          assert_equal(4_000, subject.spent_point)
        end
        it '利用可能ポイントは増える' do
          assert_equal(11_000, subject.available_point)
        end
      end
    end

    describe 'ポイント上限が引き下げられる' do
      before(:each) do
        reset_student(15_000, 15_000, 4_000)
        @mock = MiniTest::Mock.new.expect(:call, true)
        subject.assign_attributes following_monthly_point: 5000
        ::Credit.stub(:reserve, @mock) { subject.modify_upper_point_limit }
      end
      it '翌月ポイント上限は引き下げられる' do
        assert_equal 5000, subject.following_monthly_point
      end
      it '当月ポイント上限は変わらない' do
        assert_equal(15_000, subject.current_monthly_point)
      end
      it '消費ポイントは変わらない' do
        assert_equal(4_000, subject.spent_point)
      end
      it '::Credit.reserveは実行されない' do
        -> { @mock.verify }.must_raise(MockExpectationError)
      end
      it '利用可能ポイントは変わらない' do
        assert_equal(11_000, subject.available_point)
      end
    end
  end

  describe '#recount_unreads' do
    subject { student.recount_unreads }

    let(:student) { Student.find(3) }
    let(:question) do
      Question.create(student: student, school: school, state: :open)
    end
    let(:post) do
      Post.create(postable_type: :AdminUser,
                  state:         :accepted_unread,
                  question:      question)
    end

    before { student.update(school: school) }

    describe 'when question exists' do
      before { post }

      describe 'when school of student is c' do
        let(:school) { :c }
        it 'updates unreads column' do
          assert_not_equal 1, student.unreads
          subject
          assert_equal 1, student.reload.unreads
        end
      end

      describe 'when school of student is k' do
        let(:school) { :k }
        it 'updates unreads column' do
          assert_not_equal 1, student.unreads
          subject
          assert_equal 1, student.reload.unreads
        end
      end
    end

    describe 'when question does not exist' do
      before { student.update(unreads: 5) }

      describe 'when school of student is c' do
        let(:school) { :c }
        it 'updates unreads column' do
          assert_not_equal 0, student.unreads
          subject
          assert_equal 0, student.reload.unreads
        end
      end

      describe 'when school of student is k' do
        let(:school) { :k }
        it 'updates unreads column' do
          assert_not_equal 0, student.unreads
          subject
          assert_equal 0, student.reload.unreads
        end
      end
    end
  end

  describe '#get_condition' do
    subject { student.get_condition }
    let(:student) { Student.first }
    let(:json) do
      { c: { year: 'c3', subject: 'mathematics_regular' },
        k: { year: 'k', subject: 'english_syntax' } }
    end
    describe 'when condition is nil' do
      before { student.update condition: nil }
      it 'return default_condition' do
        assert_equal subject, Settings.default_condition[student.school].to_hash
      end
    end
    describe 'when condition is present' do
      before { student.update condition: json }
      describe 'when school is c' do
        before { student.update(school: 'c') }
        it 'return json which year is c3 and subject is mathematics_regular' do
          assert_equal subject, json.with_indifferent_access[:c]
        end
      end

      describe 'when school is k' do
        before { student.update(school: 'k') }
        it 'return json which year is k and subject is english_syntax' do
          assert_equal subject, json.with_indifferent_access[:k]
        end
      end
    end
  end

  describe '#update_condition' do
    subject do
      student.update_condition(year: year_param, subject: subject_param)
    end

    let(:student)  { Student.first }
    let(:expected) do
      { s: { year: 's1', subject: 'english' },
        c: { year: c_year_param, subject: c_subject_param },
        k: { year: k_year_param, subject: k_subject_param } }
    end
    let(:c_year_param) { 'c1' }
    let(:c_subject_param) { 'english_regular' }
    let(:k_year_param) { 'k' }
    let(:k_subject_param) { 'english_grammar' }
    before do
      student.update(condition: Settings.default_condition.to_hash)
    end

    describe 'when school is k' do
      describe 'when k subject params is mathematics_b' do
        before { student.update school: 'k' }
        let(:k_subject_param) { 'mathematics_b' }
        let(:year_param) { 'k' }
        let(:subject_param) { 'mathematics_b' }
        it 'student condition column is exptected' do
          subject
          assert_equal(student.condition.with_indifferent_access,
                       expected.with_indifferent_access)
        end
      end
    end
    describe 'when school is c' do
      describe 'when c subject params is mathematics_exam' do
        let(:c_subject_param) { 'mathematics_exam' }
        let(:year_param) { 'c1' }
        let(:subject_param) { 'mathematics_exam' }
        it 'student condition column is exptected' do
          subject
          assert_equal(student.condition.with_indifferent_access,
                       expected.with_indifferent_access)
        end
      end
    end
  end

  describe 'password_validation' do
    subject do
      Student.create!(id: 10_000, username: 'testuser1234',
                      password: password_param,
                      password_confirmation: password_param,
                      original_member_type: 'tryit',
                      current_member_type: 'tryit',
                      first_name: 'テスト',
                      family_name: 'テスト',
                      first_name_kana: 'テスト',
                      family_name_kana: 'テスト',
                      birthday: Time.now, gknn_cd: '21')
    end

    describe 'when password length is 3' do
      let(:password_param) { 'tes' }

      describe 'when environment is teacher_production' do
        it 'can create user' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')
          Rails.stub(:env, mock_env) do
            assert_raises(ActiveRecord::RecordInvalid) do
              subject
            end
          end
        end
      end

      describe 'when environment is www_production' do
        it 'can not create user' do
          mock_env = ActiveSupport::StringInquirer.new('www_production')
          Rails.stub(:env, mock_env) do
            assert_raises(ActiveRecord::RecordInvalid) do
              subject
            end
          end
        end
      end
    end

    describe 'when password length is 4' do
      let(:password_param) { 'test' }

      describe 'when environment is teacher_production' do
        it 'can create user' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')

          Rails.stub(:env, mock_env) do
            assert subject
          end
        end
      end

      describe 'when environment is www_production' do
        it 'can not create user' do
          mock_env = ActiveSupport::StringInquirer.new('www_production')
          Rails.stub(:env, mock_env) do
            assert_raises(ActiveRecord::RecordInvalid) do
              subject
            end
          end
        end
      end
    end

    describe 'when password length is 8' do
      let(:password_param) { 'testtest' }
      describe 'when environment is teacher_production' do
        it 'can create user' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')
          Rails.stub(:env, mock_env) do
            assert subject
          end
        end
      end

      describe 'when environment is www_production' do
        it 'can not create user' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')
          Rails.stub(:env, mock_env) do
            assert subject
          end
        end
      end
    end
  end

  describe 'username validation which prohibits FIST sit_cd at '\
           'not teacher_production Environment' do
    subject do
      Student.create!(id: 10_000,
                      username: username,
                      password: 'test0001',
                      password_confirmation: 'test0001',
                      original_member_type: 'tryit',
                      current_member_type: 'tryit',
                      first_name: 'テスト',
                      family_name: 'テスト',
                      first_name_kana: 'テスト',
                      family_name_kana: 'テスト',
                      birthday: Time.now,
                      gknn_cd: '21')
    end

    describe 'when environment is teacher_production' do
      describe 'when username is fist sitcd' do
        let(:username) { '12345678901' }
        it 'can create student' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')
          Rails.stub(:env, mock_env) do
            assert subject
          end
        end
      end

      describe 'when username is fist enployee sitcd' do
        let(:username) { 'TS1000' }
        it 'can create student' do
          mock_env = ActiveSupport::StringInquirer.new('teacher_production')
          Rails.stub(:env, mock_env) do
            assert subject
          end
        end
      end
    end
    describe 'when environment is not teacher_production' do
      describe 'when username is fist sitcd' do
        let(:username) { '12345678901' }
        it 'can not create student' do
          mock_env = ActiveSupport::StringInquirer.new('www_production')

          Rails.stub(:env, mock_env) do
            assert_raises(ActiveRecord::RecordInvalid) do
              subject
            end
          end
        end
      end

      describe 'when username is fist enployee sitcd' do
        let(:username) { 'TS1000' }
        it 'can not create student' do
          mock_env = ActiveSupport::StringInquirer.new('www_production')
          Rails.stub(:env, mock_env) do
            assert_raises(ActiveRecord::RecordInvalid) do
              subject
            end
          end
        end
      end
    end
  end
  describe '#valid_condition' do
    subject do
      Student.first.update_condition(year: year_param,
                                     subject: subject_param)
    end

    describe 'when school is s' do
      before { Student.first.update school: 's' }
      describe 'when subject params is valid' do
        let(:year_param) { 's' }
        let(:subject_param) { 'english' }
        it 'pass validate' do
          assert subject
        end
      end
      describe 'when subject params is invalid' do
        let(:year_param) { 'k' }
        let(:subject_param) { 'english' }
        it 'raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
    end
    describe 'when school is c' do
      before { Student.first.update school: 'c' }
      let(:year_param) { 'c' }
      describe 'when subject params is valid' do
        let(:subject_param) { 'english_regular' }
        it 'pass validate' do
          assert subject
        end
      end
      describe 'when subject params is invalid' do
        let(:subject_param) { 'english_grammar' }
        it 'raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
      describe 'when year params is invalid' do
        let(:year_param) { 'k' }
        let(:subject_param) { 'english_regular' }
        it 'raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
    end
    describe 'when school is k' do
      before { Student.first.update school: 'k' }
      let(:year_param) { 'k' }
      describe 'when subject params is valid' do
        let(:subject_param) { 'mathematics_1' }
        it 'pass validate' do
          assert subject
        end
      end
      describe 'when subject params is invalid' do
        let(:subject_param) { 'mathematics_exam' }
        it 'raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
      describe 'when year params is invalid' do
        let(:year_param) { 'c' }
        let(:subject_param) { 'english_regular' }
        it 'raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
    end
  end

  describe 'validate gknn_cd' do
    subject do
      attriubutes = Student.first.attributes
      attriubutes.delete('id')
      attriubutes.merge!(sit_cd: 'validate_gknn_cd',
                         username: 'validate_gknn_cd',
                         gknn_cd: gknn_cd_param,
                         password: 'password',
                         password_confirmation: 'password')
      Student.new(attriubutes)
    end

    describe 'when gknn_cd is included GknnCd::Map' do
      let(:gknn_cd_param) { GknnCd::Map.keys.sample }
      it 'can create user' do
        assert subject.valid?
      end
    end

    describe 'when gknn_cd is excluded GknnCd::Map' do
      let(:gknn_cd_param) { '29' }
      it 'occur validation error' do
        mock_env = ActiveSupport::StringInquirer.new('teacher_production')
        Rails.stub(:env, mock_env) do
          assert_not subject.valid?
        end
      end
    end
  end

  describe '#change_member_type' do
    subject { student.change_member_type(type_param) }
    describe 'when type param is cancel' do
      let(:type_param) { 'cancel' }
      describe 'when sit_cd is present' do
        let(:student) { Student.where.not(sit_cd: [nil, '']).first }
        it 'current_member_type be fist' do
          subject
          assert_equal 'fist', student.current_member_type
        end
      end
      describe 'when sit_cd is present' do
        let(:student) { Student.where(sit_cd: [nil, '']).first }
        it 'current_member_type be fist' do
          subject
          assert_equal 'tryit', student.current_member_type
        end
      end
    end
    describe 'when type param is tester' do
      let(:type_param) { 'tester' }
      let(:student) { Student.first }
      it 'current_member_type be tester' do
        subject
        assert_equal 'tester', student.current_member_type
      end
    end
  end

  describe 'translate hurigana from hiragana to katakana before save' do
    before do
      # これがないとPG::UniqueViolation: ERRORとなる。
      ActiveRecord::Base.connection.execute(
        "ALTER SEQUENCE students_id_seq RESTART WITH #{Student.last.id + 1}"
      )
    end
    describe 'when create' do
      subject { Student.create(student_attributes) }
      let(:student_attributes) do
        { school: 'c',
          username: 'testtest',
          password: 'test0001',
          password_confirmation: 'test0001',
          family_name: 'テスト',
          first_name: '一郎',
          family_name_kana: family_name_kana_param,
          first_name_kana: first_name_kana_param,
          sex: 'male',
          birthday: '2000-01-01',
          gknn_cd: '21',
          state: 'active',
          original_member_type: 'tryit',
          current_member_type: 'tryit',
          schoolbooks: Settings.default_schoolbooks_settings['c'].to_hash,
          parent_id: 1,
          current_month: Time.now.strftime('%Y%m').to_i,
          school_name: '.' }
      end

      describe 'when hiragana' do
        let(:family_name_kana_param) { 'ふぁみりーねーむ' }
        let(:first_name_kana_param) { 'ふぁーすとねーむ' }
        it 'first_name_kana and family_name_kana be katakana' do
          student = subject
          assert_equal 'ファミリーネーム', student.family_name_kana
          assert_equal 'ファーストネーム', student.first_name_kana
        end
      end
      describe 'when hankaku katakana' do
        let(:family_name_kana_param) { 'ﾌｧﾐﾘｰﾈｰﾑ' }
        let(:first_name_kana_param) { 'ﾌｧｰｽﾄﾈｰﾑ' }
        it 'first_name_kana and family_name_kana be katakana' do
          student = subject
          assert_equal 'ファミリーネーム', student.family_name_kana
          assert_equal 'ファーストネーム', student.first_name_kana
        end
      end
    end

    describe 'when update' do
      subject do
        student.update(first_name_kana: first_name_kana_param,
                       family_name_kana: family_name_kana_param)
      end

      let(:student) { Student.first }

      describe 'when hiragana' do
        let(:family_name_kana_param) { 'ふぁみりーねーむ' }
        let(:first_name_kana_param) { 'ふぁーすとねーむ' }
        it 'first_name_kana and family_name_kana be katakana' do
          subject
          assert_equal 'ファミリーネーム', student.family_name_kana
          assert_equal 'ファーストネーム', student.first_name_kana
        end
      end

      describe 'when hankaku katakana' do
        let(:family_name_kana_param) { 'ﾌｧﾐﾘｰﾈｰﾑ' }
        let(:first_name_kana_param) { 'ﾌｧｰｽﾄﾈｰﾑ' }
        it 'first_name_kana and family_name_kana be katakana' do
          subject
          assert_equal 'ファミリーネーム', student.family_name_kana
          assert_equal 'ファーストネーム', student.first_name_kana
        end
      end
    end
  end

  describe 'validate username not to include @' do
    before do
      # これがないとPG::UniqueViolation: ERRORとなる。
      ActiveRecord::Base.connection.execute(
        "ALTER SEQUENCE students_id_seq RESTART WITH #{Student.last.id + 1}"
      )
    end

    describe '#update' do
      before do
        Student.first.update_attribute(:username, 'testtete@userheoreho')
      end

      subject { Student.first.update!(student_attributes) }
      let(:student_attributes) do
        { school: 'c',
          password: 'test0001',
          password_confirmation: 'test0001',
          family_name: 'テスト',
          first_name: '一郎',
          family_name_kana: 'テスト',
          first_name_kana: 'テスト',
          sex: 'male',
          birthday: '2000-01-01',
          gknn_cd: '21',
          state: 'active',
          original_member_type: 'tryit',
          current_member_type: 'tryit',
          schoolbooks: Settings.default_schoolbooks_settings['c'].to_hash,
          parent_id: 1,
          current_month: Time.now.strftime('%Y%m').to_i,
          school_name: '.' }
      end

      describe 'when username is included @' do
        let(:username_param) { 'testtete@userheoreho' }
        it 'should can update' do
          assert subject
        end
      end
    end

    describe '#create' do
      subject do
        student = Student.new(student_attributes)
        student.create_mode = create_mode_param
        student.update_mode = update_mode_param
        student.save!
      end

      let(:create_mode_param) { nil }
      let(:update_mode_param) { nil }
      let(:student_attributes) do
        { school: 'c',
          username: username_param,
          password: 'test0001',
          password_confirmation: 'test0001',
          family_name: 'テスト',
          first_name: '一郎',
          family_name_kana: 'テスト',
          first_name_kana: 'テスト',
          sex: 'male',
          birthday: '2000-01-01',
          gknn_cd: '21',
          state: 'active',
          original_member_type: 'tryit',
          current_member_type: 'tryit',
          schoolbooks: Settings.default_schoolbooks_settings['c'].to_hash,
          parent_id: 1,
          current_month: Time.now.strftime('%Y%m').to_i,
          school_name: '.' }
      end

      describe 'when username is included @' do
        let(:username_param) { 'test@gmail.com' }
        describe 'when create_mode is nil' do
          it 'can save' do
            assert subject
          end
        end

        describe 'when create_mode is additional' do
          let(:create_mode_param) { :additional }
          it 'should raise Execption' do
            assert_raise ActiveRecord::RecordInvalid do
              subject
            end
          end
        end
      end

      describe 'when username is not included @' do
        let(:username_param) { 'test.com' }
        it 'can save' do
          assert subject
        end
      end
    end
  end

  describe '#purchasable?' do
    let(:student) { Student.first }

    it 'should respond_to purchasable?' do
      assert student.respond_to?(:purchasable?)
    end
  end

  describe '#with_teacher?' do
    subject { student.with_teacher? }
    let(:student) { Student.find_by(current_member_type: member_type_param) }
    let(:member_type_param) { 'tryit' }

    it 'should respond_to purchasable?' do
      assert student.respond_to?(:with_teacher?)
    end

    it 'should return false' do
      assert_equal false, subject
    end

    describe 'when type is tryit' do
      let(:member_type_param) { 'tryit' }

      it 'should return true' do
        assert_equal(false, subject)
      end
    end

    describe 'when type is tester' do
      let(:member_type_param) { 'tester' }

      it 'should return true' do
        assert_equal(true, subject)
      end
    end

    describe 'when type is fist' do
      let(:member_type_param) { 'fist' }

      it 'should return true' do
        assert_equal(true, subject)
      end
    end
  end

  describe '#new_user?' do
    subject { student.new_user? }

    let(:student)       { parent.students.take }
    let(:parent)        { Parent.first }
    let(:new_user_date) { Time.zone.parse(Settings.new_user_date) }

    dates = %w(created_at confirmed_at confirmation_sent_at)
    dates.permutation.each do |date1, date2, date3|
      describe "when #{date1} <= new_user_date" do
        before { parent.update!(date1 => new_user_date) }

        describe "when #{date2} >= new_user_date" do
          before { parent.update!(date2 => new_user_date) }

          describe "when #{date3} is nil" do
            before { parent.update!(date3 => nil) }

            describe 'without kiyksh_cd' do
              it { assert_equal true, subject }
            end

            describe 'with kiyksh_cd' do
              before { parent.update!(kiyksh_cd: 'xxxxxxxxxxx') }
              it { assert_equal false, subject }
            end
          end
        end
      end
    end
  end

  describe 'school_name validation' do
    before do
      # これがないとPG::UniqueViolation: ERRORとなる。
      ActiveRecord::Base.connection.execute(
        "ALTER SEQUENCE students_id_seq RESTART WITH #{Student.last.id + 1}"
      )
      @student = Student.new
    end

    let(:student_params) do
      {
        username: Time.current.to_i,
        gknn_cd: gknn_cd_params,
        sex: 'male',
        school_name: school_name_params,
        family_name: '渡来',
        first_name: '太郎',
        family_name_kana: 'トライ',
        first_name_kana: 'タロウ',
        original_member_type: 'tryit',
        current_member_type: 'tryit',
        birthday: Time.current,
        password: 'test0001',
        password_confirmation: 'test0001'
      }
    end
    let(:gknn_cd_params) { '21' }

    subject do
      @student.assign_attributes(student_params)
      @student.save!
      @student.activate
    end

    describe 'when create_mode is :additional' do
      before do
        @student.create_mode = :additional
      end

      describe 'when school_name is not present' do
        let(:school_name_params) { '' }

        it 'should raise ActiveRecord::RecordInvalid' do
          assert_raise(ActiveRecord::RecordInvalid) do
            subject
          end
        end
        describe 'when gknn_cd is 60' do
          let(:gknn_cd_params) { '60' }

          it 'should success to create' do
            subject
            assert_equal('active', @student.state)
          end
        end
      end

      describe 'when school_name is not present' do
        let(:school_name_params) { 'テスト' }
        before do
          @student.create_mode = :additional
        end

        it 'should success to create' do
          subject
          assert_equal('active', @student.state)
        end
      end
    end
  end

  describe 'before validation' do
    before do
      @student = Student.first
    end

    describe 'with password and password_confirmation' do
      subject do
        @student.update!(password: password,
                         password_confirmation: password)
      end
      let(:password) { 'HogeHogeTUEN09_1bo3' }

      it 'password should be saved as downcase' do
        subject
        @student.reload

        assert(@student.valid_password?(password.downcase),
               'Student password should be downcase')
      end
    end

    describe 'family_name_kana and first_name_kana convert' do
      before do
        @student.family_name_kana = family_name_kana
        @student.first_name_kana = first_name_kana
      end
      subject { @student.save }
      describe 'family_name_kana and first_name_kana is nil' do
        let(:family_name_kana) { nil }
        let(:first_name_kana) { nil }

        it 'should be noop' do
          called = false
          proc = ->(_, _) { called = true }

          NKF.stub(:nkf, proc) do
            subject
          end

          assert_equal(false, called)
        end
      end

      describe 'with Hiragana' do
        let(:family_name_kana) { 'せい' }
        let(:first_name_kana) { 'めい' }

        it 'NKF::nkf should be called' do
          called = false
          proc = ->(_, _) { called = true }

          NKF.stub(:nkf, proc) do
            subject
          end

          assert(called, 'should be called NKF::nkf')
        end

        it 'family_name_kana & first_name_kana should be converted to kana' do
          subject
          assert_equal('セイ', @student.family_name_kana)
          assert_equal('メイ', @student.first_name_kana)
        end
      end

      describe 'with half-width kana' do
        let(:family_name_kana) { 'ｾｲ' }
        let(:first_name_kana) { 'ﾒｲ' }

        it 'NKF::nkf should be called' do
          called = false
          proc = ->(_, _) { called = true }

          NKF.stub(:nkf, proc) do
            subject
          end

          assert(called, 'should be called NKF::nkf')
        end

        it 'family_name_kana & first_name_kana should be converted to kana' do
          subject
          assert_equal('セイ', @student.family_name_kana)
          assert_equal('メイ', @student.first_name_kana)
        end
      end
    end
  end

  describe '#unread_news_num' do
    let(:student) { Student.find(2) }
    it { assert_equal 1, student.news_students.unreads.size }
  end

  describe '#unread_recommendation_num' do
    let(:student) { Student.find(1) }
    it { assert_equal 36, student.teacher_recommendations.notifiable.unreads.size }
  end

  describe '#unread_notification_num' do
    let(:student) { Student.find(2) }
    it { assert_equal 1, student.unread_news_num + student.unread_recommendation_num }
  end

  describe '#authenticate' do
    subject { Student.authenticate(params) }

    describe 'when params valid' do
      let(:params) { { 'studentId' => 'test0001', 'password' => 'test0001' } }
      it 'returns student' do
        assert_equal Student, subject.class
      end
    end

    describe 'when password invalid' do
      let(:params) { { 'studentId' => 'test0001', 'password' => 'invalid' } }
      it 'returns false' do
        assert_equal false, subject
      end
    end

    describe 'when params invalid' do
      let(:params) { { 'studentId' => 'invalid', 'password' => 'invalid' } }
      it 'returns false' do
        assert_equal false, subject
      end
    end
  end

  describe '#settings_point_limits?' do
    subject { student.settings_point_limits? }

    let(:student) { Student.first }
    describe 'when current_monthly_point > 0' do
      it 'returns true' do
        student.update(current_monthly_point: 15000)
        assert_equal true, subject
      end
    end

    describe 'when current_monthly_point = 0' do
      it 'returns false' do
        student.update(current_monthly_point: 0)
        assert_equal false, subject
      end
    end
  end

  describe '#fist?' do
    subject { student.fist? }

    let(:student) { Student.first }
    describe 'when current_member_type is fist' do
      it 'returns true' do
        student.update(current_member_type: 'fist')
        assert_equal true, subject
      end
    end

    describe 'when current_member_type is not fist' do
      it 'returns false' do
        student.update(current_member_type: 'tryit')
        assert_equal false, subject
      end
    end
  end

  describe '#get_schoolbook_id' do
    subject { student.get_schoolbook_id(params[:year], params[:subject]) }
    let(:student) { Student.first }

    describe 'when subject end with standard or high-level' do
      let(:params) { { year: 'k', subject: 'physics_basis-standard' } }

      it 'returns schoolbook id is 508' do
        assert_equal 508, subject
      end
    end

    describe 'when subject is japanese_classics' do
      let(:params) { { year: 'c1', subject: 'japanese_classics' } }

      it 'returns schoolbook id is 317' do
        assert_equal 317, subject
      end
    end

    describe 'when subject is japanese_chinese_classics' do
      let(:params) { { year: 'c2', subject: 'japanese_chinese_classics' } }

      it 'returns schoolbook id is 318' do
        assert_equal 318, subject
      end
    end

    describe 'when subject from student' do
      let(:params) { { year: 'c3', subject: 'english_regular' } }

      it 'returns schoolbook id is 3' do
        assert_equal 3, subject
      end
    end
  end

  describe '#update_schoolbooks' do
    subject { student.update_schoolbooks(schoolbooks) }
    let(:student) { Student.first }

    describe 'when schoolbooks valid' do
      let(:schoolbooks) { schoolbooks_json }
      it 'returns true' do
        assert_equal true, subject
      end
    end
  end

  describe '#level_progress' do
    subject { student.level_progress }
    let(:student) { Student.first }

    it 'returns 28.57142857142857 exp' do
      assert_equal 28.57142857142857, subject
    end
  end

  describe '#experience_point_for_next_level' do
    subject { student.experience_point_for_next_level }
    let(:student) { Student.first }

    it 'returns 500 exp' do
      assert_equal 500, subject
    end
  end
end
