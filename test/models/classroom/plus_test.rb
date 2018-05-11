require 'test_helper'

class Classroom::PlusTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(tmp_cd name prefecture_code).each do |column|
      describe 'with presence' do
        subject { Classroom::Plus.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(tmp_cd name).each do |column|
      describe 'with length' do
        subject { Classroom::Plus.new(column => string) }

        describe 'with too_short texts' do
          let(:length) { "Classroom::MIN_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length - 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_short', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end

        describe 'with too_long texts' do
          let(:length) { "Classroom::MAX_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length + 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_long', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end
      end
    end

    %i(tmp_cd).each do |column|
      describe 'with uniqueness' do
        subject { Classroom::Plus.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(type prefecture_code status).each do |column|
      describe 'with inclusion' do
        subject { Classroom::Plus.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end
  end
end
