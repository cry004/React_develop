require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include ActionDispatch::TestProcess

  describe '#validations' do
    %i(message title content published_at).each do |column|
      describe 'with presence' do
        subject { News.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(message title content).each do |column|
      describe 'with length' do
        subject { News.new(column => string) }

        describe 'with too_short texts' do
          let(:length) { "News::MIN_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length - 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_short', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end

        describe 'with too_long texts' do
          let(:length) { "News::MAX_#{column.upcase}_LENGTH".constantize }
          let(:string) { 'x' * (length + 1) }
          let(:expected_msg) { I18n.t('errors.messages.too_long', count: length) }

          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], expected_msg
          end
        end
      end
    end

    describe 'with published_at_cannot_be_in_the_past' do
      subject { News.new(published_at: 1.day.ago) }

      it 'rejects a bad record in validation' do
        assert subject.invalid?
        assert_includes subject.errors[:published_at], I18n.t('errors.messages.invalid')
      end
    end
  end

  describe '#publish' do
    subject { news.publish }

    let(:news) { News.take.dup }

    before { news.save! }

    describe 'when news is publishable' do
      let(:count) { Student.news_deliverable.size }

      it 'saves news_students records for all active students' do
        news.stub(:publishable?, true) do
          Device.stub(:bulk_notify, true) do
            assert_difference 'NewsStudent.count', count do
              subject
            end
          end
        end
      end

      it 'calls Device.bulk_notify method' do
        called = false
        proc = -> (_, _, _) { called = true }
        news.stub(:publishable?, true) do
          Device.stub(:bulk_notify, proc) do
            subject
          end
        end
        assert(called)
      end
    end

    describe 'when news is not publishable' do
      it 'saves news_students records for all active students' do
        news.stub(:publishable?, false) do
          assert_raise Exceptions::NewsPublicationError do
            subject
          end
        end
      end
    end
  end

  describe 'callbacks after destroying' do
    subject { news.destroy }

    let(:news) { News.take.dup }

    let(:file) do
      fixture_file_upload('files/login_mrtry.png', 'image/png')
    end

    before do
      photo = NewsContentPhoto.create!(data: file)
      news_content = "<p><img alt='' src='#{photo.data.remote_url}' style='width: 344px; height: 385px;' /></p>"
      news.content = news_content
      news.save!
    end

    it 'has file source in content' do
      files = Nokogiri::HTML(news.content).css('img').map { |node| node['src'] }
      assert_equal 1, files.length
    end

    it '#remove files after destroying news' do
      assert_difference 'NewsContentPhoto.count', -1 do
        subject
      end
    end
  end
end
