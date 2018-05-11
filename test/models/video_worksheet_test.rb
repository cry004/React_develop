require 'test_helper'

class VideoWorksheetTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(video_id worksheet_id).each do |column|
      describe 'with presence' do
        subject { VideoWorksheet.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(worksheet_id).each do |column|
      describe 'with uniqueness' do
        subject { VideoWorksheet.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end
  end
end
