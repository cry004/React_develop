require 'test_helper'

class VideoTagTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(video name values priority).each do |column|
      describe 'with presence' do
        subject { VideoTag.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(name).each do |column|
      describe 'with uniqueness' do
        subject { VideoTag.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
