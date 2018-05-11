require 'test_helper'

class NewsStudentTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(news student).each do |column|
      describe 'with presence' do
        subject { NewsStudent.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(news_id).each do |column|
      describe 'with uniqueness' do
        subject { NewsStudent.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(unread).each do |column|
      describe 'with inclusion' do
        subject { NewsStudent.new(column => nil) }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end
  end
end
