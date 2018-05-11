require 'test_helper'

class ParentTest < ActiveSupport::TestCase
  def env_mock(name)
    ActiveSupport::StringInquirer.new(name)
  end

  subject { Parent.first }

  describe 'クレジットカード' do
    describe '削除できる' do
      before do
        subject.students.each {|student| student.update_attribute :current_monthly_point, 0}
      end
      it { assert_equal true, subject.creditcard_destroyable? }
    end

    describe '削除できない' do
      before do
        subject.students.each {|student| student.update_attribute :current_monthly_point, 5000 }
      end
      it { assert_equal false, subject.creditcard_destroyable? }
    end

    describe '削除できない' do
      before { subject.students.first.update_attribute :current_monthly_point, 10000 }
      it { assert_equal false, subject.creditcard_destroyable? }
    end
  end

  describe '#human_zip' do
    subject { parent.human_zip }
    let(:parent) do
      Parent.first.update_attributes! zip: zip_param
      Parent.first
    end

    describe 'zip include hyphen' do
      let(:zip_param) { '100-1000' }
      it 'should return valid human zip' do
        assert_equal '100-1000', subject
      end
    end

    describe 'zip not include hyphen' do
      let(:zip_param) { '1001000' }
      it 'should return valid human zip' do
        assert_equal '100-1000', subject
      end
    end
  end

  describe '#purchasable?' do
    subject { parent.purchasable? }
    let(:parent) { Parent.first }

    it 'should called purchasable_at_domestic?' do
      called = false
      proc = -> { called = true }

      Parent.stub_any_instance(:purchasable_at_domestic?, proc) do
        subject
      end

      assert called
    end

    describe 'when purchasable_at_domestic? return false' do
      it 'should called purchasable_at_foreign?' do
        called = false
        proc = -> { called = true }

        Parent.stub_any_instance(:purchasable_at_domestic?, false) do
          Parent.stub_any_instance(:purchasable_at_foreign?, proc) do
            subject
          end
        end

        assert called
      end
    end
  end

  describe 'purchasable_at_domestic?' do
    subject { parent.purchasable_at_domestic? }
    let(:parent) { Parent.find_by(params) }

    describe 'when domestic is true' do
      let(:domestic_params) { true }

      describe 'when nessesary_attrs_for_purchase is present' do
        let(:params) do
          { domestic: domestic_params, email: 'example@example.com' }
        end

        it 'should return true' do
          assert_equal true, subject
        end
      end

      describe 'when nessesary_attrs_for_purchase is not present' do
        let(:params) do
          { domestic: domestic_params, email: 'not_purchasable@example.com' }
        end

        it 'should return false' do
          assert_equal false, subject
        end
      end
    end
    describe 'when domestic is false' do
      let(:domestic_params) { false }

      let(:params) do
        { domestic: domestic_params, foreign_address: '外国' }
      end

      it 'should return false' do
        assert_equal false, subject
      end
    end
  end

  describe 'purchasable_at_foreign?' do
    subject { parent.purchasable_at_foreign? }
    let(:parent) { Parent.find_by(params) }

    describe 'when domestic is true' do
      let(:domestic_params) { true }
      let(:params) do
        { domestic: domestic_params }
      end

      it 'should return false' do
        assert_equal false, subject
      end
    end

    describe 'when domestic is false' do
      let(:domestic_params) { false }

      describe 'when foreign_address is present' do
        let(:params) do
          { domestic: domestic_params, foreign_address: '外国' }
        end

        it 'should return true' do
          assert_equal true, subject
        end
      end

      describe 'when foreign_address is not present' do
        let(:params) do
          { domestic: domestic_params, foreign_address: nil }
        end
        it 'should return false' do
          assert_equal false, subject
        end
      end
    end
  end

  describe '#nessesary_attrs_for_purchase' do
    subject { parent.nessesary_attrs_for_purchase }
    let(:parent) { Parent.first }
    let(:nessesary_attrs) do
      Set.new(%w(zip prefecture_code city address1 tel))
    end

    it 'should return nessesary_attrs hash' do
      assert_equal nessesary_attrs, Set.new(subject.keys)
    end
  end

  describe '#new_user?' do
    subject { parent.new_user? }

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

  describe 'password_validation' do
    let(:length_validate_message_4) do
      ['は4文字以上で入力してください。']
    end

    let(:length_validate_message_8) do
      ['は8文字以上で入力してください。']
    end

    subject do
      @parent = Parent.new(password: password_param,
                           password_confirmation: password_param)
      @parent.valid?
    end

    describe 'when password length is 3' do
      let(:password_param) { 'tes' }

      describe 'when environment is teacher_production' do
        it 'should raise password validation error' do
          Rails.stub(:env, env_mock('teacher_production')) do
            Parent.clear_validators!
            load './app/models/parent.rb'
            subject

            assert_equal(length_validate_message_4,
                         @parent.errors[:password])
          end
        end
      end

      describe 'when environment is www_production' do
        it 'should raise password validation error' do
          Rails.stub(:env, env_mock('www_production')) do
            Parent.clear_validators!
            load './app/models/parent.rb'

            subject
            assert_equal(length_validate_message_8,
                         @parent.errors[:password])
          end
        end
      end
    end

    describe 'when password length is 4' do
      let(:password_param) { 'test' }

      describe 'when environment is teacher_production' do
        it 'should not raise password validation error' do
          Rails.stub(:env, env_mock('teacher_production')) do
            Parent.clear_validators!
            load './app/models/parent.rb'
            subject

            assert(@parent.errors[:password].blank?)
          end
        end
      end

      describe 'when environment is www_production' do
        it 'should raise password validation error' do
          Rails.stub(:env, env_mock('www_production')) do
            Parent.clear_validators!
            load './app/models/parent.rb'

            subject

            assert_equal(length_validate_message_8,
                         @parent.errors[:password])
          end
        end
      end
    end

    describe 'when password length is 8' do
      let(:password_param) { 'testtest' }
      describe 'when environment is teacher_production' do
        it 'should not raise password validation error' do
          Rails.stub(:env, env_mock('teacher_production')) do
            Parent.clear_validators!
            load './app/models/parent.rb'

            subject
            assert(@parent.errors[:password].blank?)
          end
        end
      end

      describe 'when environment is www_production' do
        it 'should not raise password validation error' do
          Rails.stub(:env, env_mock('www_production')) do
            subject
            assert(@parent.errors[:password].blank?)
          end
        end
      end
    end
  end

  describe 'before validation' do
    before do
      @parent = Parent.first
    end

    describe 'with password and password_confirmation' do
      subject do
        @parent.update!(password: password,
                        password_confirmation: password)
      end
      let(:password) { 'HogeHogeTUEN09_1bo3' }

      it 'password should be saved as downcase' do
        subject
        @parent.reload

        assert(@parent.valid_password?(password.downcase),
              'Parent password should be downcase')
      end
    end
  end
end
