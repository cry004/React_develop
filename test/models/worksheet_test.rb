require 'test_helper'

class WorksheetTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(category type url).each do |column|
      describe 'with presence' do
        subject { Worksheet.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(url).each do |column|
      describe 'with uniqueness' do
        subject { Worksheet.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(type category).each do |column|
      describe 'with inclusion' do
        subject { Worksheet.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end

    describe 'with custom validator' do
      Worksheet::CATEGORIES.each do |category|
        describe '#ensyu_and_syutoku_can_not_be_combined_with_question' do
          subject { Worksheet.new(category: category, type: type) }
          let(:type) { 'question' }

          it "rejects a bad combination of category: '#{category}' and type: 'question' in validation" do
            assert subject.invalid?(:category)

            # NOTE: There is no worksheet with category: ('ensyu'||'syutoku')  and type: 'question'
            # HACK: Refactor error messages in appropriate wording and place
            assert_includes subject.errors[:category],
              "category: '#{category}' and type: 'question' can not be combined"
          end
        end

        describe '#url_must_be_in_the_expected_format' do
          subject { Worksheet.new(category: category, type: type, url: url) }

          let(:type) { 'answer' }
          let(:url)  { 'invalid_format' }

          it 'must be the expected URL format' do
            assert subject.invalid?(:url)
            assert_includes subject.errors[:url],
              " doesn't looks like in the expected format"
          end
        end
      end
    end
  end
end
