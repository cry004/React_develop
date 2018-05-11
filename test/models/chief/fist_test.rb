require 'test_helper'

class Chief::FistTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(shin_cd).each do |column|
      describe 'with presence' do
        subject { Chief::Fist.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(shin_cd).each do |column|
      describe 'with uniqueness' do
        subject { Chief::Fist.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
