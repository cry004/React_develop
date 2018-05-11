require 'test_helper'

class VideoViewingTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(video student viewed_time).each do |column|
      describe 'with presence' do
        subject { VideoViewing.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(viewed_time).each do |column|
      describe 'with numericality' do
        subject { VideoViewing.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.not_a_number')
        end
      end
    end
  end

  describe '#scopes' do
    describe '#date_range' do
      subject { VideoViewing.date_range(from, to) }

      let(:record) { VideoViewing.take }
      let(:from)   { '2017-01-01'.to_date }
      let(:to)     { '2017-01-02'.to_date }

      describe 'with created_at < from' do
        before { record.update!(created_at: from - 1.second) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).exclude?(record.id)
        end
      end

      describe 'with from == created_at' do
        before { record.update!(created_at: from) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).include?(record.id)
        end
      end

      describe 'with from < created_at < to' do
        before { record.update!(created_at: from + 1.second) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).include?(record.id)
        end
      end

      describe 'with created_at == to' do
        before { record.update!(created_at: to) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).exclude?(record.id)
        end
      end

      describe 'with to < created_at' do
        before { record.update!(created_at: to + 1.second) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).exclude?(record.id)
        end
      end

      describe 'with created_at == from' do
        before { record.update!(created_at: from) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).include?(record.id)
        end
      end

      describe 'with created_at == from' do
        before { record.update!(created_at: from) }
        it 'returns only records created between the range' do
          assert subject.pluck(:id).include?(record.id)
        end
      end
    end

    describe '#ranking_countable' do
      subject { VideoViewing.ranking_countable }

      let(:unrankable) { Student.take }

      before { unrankable.update!(private_flag: false) }

      it 'returns only records with rankable students' do
        assert subject.pluck(:student_id).exclude?(unrankable.id)
      end
    end

    describe '#watched' do
      subject { VideoViewing.watched }

      let(:unwatched) { VideoViewing.find(22) } # from fixtures

      before do
        unwatched.update!(watched: 'false', viewed_time: 0)
      end

      it 'returns only watched records' do
        assert subject.pluck(:id).exclude?(unwatched.id)
      end
    end
  end

  describe '#before_save' do
    describe '#set_watched' do
      subject do
        history = record.dup
        history.viewed_time = viewed_time
        history.save!
        history
      end

      let(:record) { VideoViewing.take }

      describe 'when threshold < video.duration' do
        let(:threshold) { VideoViewing::WATCHED_THRESHOLD }

        describe 'when threshold < viewed_time' do
          let(:viewed_time) { threshold + 1.second }

          it 'saves with watched true' do
            assert subject.persisted?
            assert_equal true, subject.watched
          end
        end

        describe 'when viewed_time == threshold' do
          let(:viewed_time) { threshold }

          it 'saves with watched true' do
            assert subject.persisted?
            assert_equal true, subject.watched
          end
        end

        describe 'when viewed_time < threshold' do
          let(:viewed_time) { threshold - 1.second }

          it 'saves with watched false' do
            assert subject.persisted?
            assert_equal false, subject.watched
          end
        end
      end

      describe 'when video.duration < threshold' do
        let(:video_duration) { 1.minute }

        before { record.video.update!(duration: video_duration) }

        describe 'when video_duration < viewed_time' do
          let(:viewed_time) { video_duration + 1.second }

          it 'saves with watched true' do
            assert subject.persisted?
            assert_equal true, subject.watched
          end
        end

        describe 'when viewed_time == video_duration' do
          let(:viewed_time) { video_duration }

          it 'saves with watched true' do
            assert subject.persisted?
            assert_equal true, subject.watched
          end
        end

        describe 'when viewed_time < video_duration' do
          let(:viewed_time) { video_duration - 1.second }

          it 'saves with watched false' do
            assert subject.persisted?
            assert_equal false, subject.watched
          end
        end
      end
    end

    describe '#set_experience_point_video' do
      subject do
        history = record.dup
        history.video = video
        history.experience_point = 0
        history.save!
        history
      end

      let(:record) { VideoViewing.take }

      describe 'when unwatched' do
        let(:video) { record.video }

        before do
          record.update!(watched: 'false', viewed_time: 0)
        end

        it 'saves with experience_point 0' do
          assert subject.persisted?
          assert_equal 0, subject.experience_point
        end
      end

      describe 'when video has been seen' do
        let(:video) { Video.find(1) } # from fixtures

        it 'saves with experience_point 50' do
          assert subject.persisted?
          assert_equal 50, subject.experience_point
        end
      end

      describe 'when video is high-level' do
        let(:video) { Video.find(6412) } # from fixtures

        it 'saves with experience_point 300' do
          assert subject.persisted?
          assert_equal 300, subject.experience_point
        end
      end

      describe 'when video is standard' do
        let(:video) { Video.find(6353) } # from fixtures

        it 'saves with experience_point 200' do
          assert subject.persisted?
          assert_equal 200, subject.experience_point
        end
      end

      describe 'when video is regular' do
        let(:video) { Video.find(29) } # from fixtures

        it 'saves with experience_point 100' do
          assert subject.persisted?
          assert_equal 100, subject.experience_point
        end
      end
    end

    describe '#set_experience_point_unit' do
      subject do
        history = record.dup
        history.video = video
        history.experience_point = 0
        history.save!
        history
      end

      let(:record) { VideoViewing.take }

      describe 'when unwatched' do
        let(:video) { record.video }

        before do
          record.update!(watched: 'false', viewed_time: 0)
        end

        it 'saves with experience_point 0' do
          assert subject.persisted?
          assert_equal 0, subject.experience_point
        end
      end

      describe 'when video is high-level and last video in unit' do
        let(:video) { Video.find(6157) } # from fixtures

        it 'saves with experience_point 1300' do
          assert subject.persisted?
          assert_equal 1300, subject.experience_point
        end
      end

      describe 'when video is standard and last video in unit' do
        let(:video) { Video.find(6166) } # from fixtures

        it 'saves with experience_point 1200' do
          assert subject.persisted?
          assert_equal 1200, subject.experience_point
        end
      end

      describe 'when video is exam and last video in unit' do
        let(:video) { Video.find(102) } # from fixtures

        it 'saves with experience_point 1100' do
          assert subject.persisted?
          assert_equal 1100, subject.experience_point
        end
      end

      describe 'when video is regular and last video in unit' do
        let(:video) { Video.find(871) } # from fixtures

        it 'saves with experience_point 1100' do
          (863..870).each do |video_id|
            history = record.dup
            history.video_id = video_id
            history.save!
            history
          end
          assert subject.persisted?
          assert_equal 1100, subject.experience_point
        end
      end

      describe 'when video is regular and last video in unit and last video in schoolbook' do
        let(:video) { Video.find(1121) } # from fixtures

        it 'saves with experience_point 3100' do
          (1070..1120).each do |video_id|
            history = record.dup
            history.video_id = video_id
            history.save!
            history
          end
          assert subject.persisted?
          assert_equal 3100, subject.experience_point
        end
      end

      describe 'when video is exam and last video in unit and last video in schoolbook' do
        let(:video) { Video.find(114) } # from fixtures

        it 'saves with experience_point 3100' do
          (102..113).each do |video_id|
            history = record.dup
            history.video_id = video_id
            history.save!
            history
          end
          assert subject.persisted?
          assert_equal 3100, subject.experience_point
        end
      end

      describe 'when video is high-level and last video in unit and last video in schoolbook' do
        let(:video) { Video.find(6495) } # from fixtures

        it 'saves with experience_point 3300' do
          ((6157..6165).to_a + (6486..6494).to_a).each do |video_id|
            history = record.dup
            history.video_id = video_id
            history.save!
            history
          end
          assert subject.persisted?
          assert_equal 3300, subject.experience_point
        end
      end

      describe 'when video is standard and last video in unit and last video in schoolbook' do
        let(:video) { Video.find(6485) } # from fixtures

        it 'saves with experience_point 3200' do
          ((6166..6174).to_a + (6477..6484).to_a).each do |video_id|
            history = record.dup
            history.video_id = video_id
            history.save!
            history
          end
          assert subject.persisted?
          assert_equal 3200, subject.experience_point
        end
      end
    end

    describe '#re_viewing?' do
      subject { record.send(:re_viewing?) }

      describe 'when video has been seen' do
        let(:record) { VideoViewing.take.dup }
        it { assert subject }
      end

      describe 'when video has not been seen' do
        let(:record) { VideoViewing.new }
        it { assert_not subject }
      end
    end
  end
end
