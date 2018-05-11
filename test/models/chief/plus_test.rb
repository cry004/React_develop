require 'test_helper'

class Chief::PlusTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(classroom_id).each do |column|
      describe 'with presence' do
        subject { Chief::Plus.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(classroom_id).each do |column|
      describe 'with uniqueness' do
        subject { Chief::Plus.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
