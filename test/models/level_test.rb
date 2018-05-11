require 'test_helper'

class LevelTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(level experience_point).each do |column|
      describe 'with presence' do
        subject { Level.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(level experience_point).each do |column|
      describe 'with uniqueness' do
        subject { Level.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
