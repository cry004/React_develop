require "test_helper"

class PeriodTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(str_period_id).each do |column|
      describe 'with presence' do
        subject { Period.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end
  
    %i(str_period_id).each do |column|
      describe 'with length' do
        subject { Period.new(column => string) }

        describe 'with too_short texts' do
          let(:length) { "Period::MIN_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length - 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_short', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end

        describe 'with too_long texts' do
          let(:length) { "Period::MAX_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length + 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_long', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end
      end
    end

    %i(str_period_id).each do |column|
      describe 'with uniqueness' do
        subject { Period.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
