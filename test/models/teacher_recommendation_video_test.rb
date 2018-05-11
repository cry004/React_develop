require 'test_helper'

class TeacherRecommendationVideoTest < ActiveSupport::TestCase
  describe 'counter_culture' do
    let(:recommend) { TeacherRecommendation.create(school: school) }
    let(:school)    { video.schoolyear.first }
    let(:video)     { Video.take }

    subject do
      recommend.teacher_recommendation_videos.create!(
        video: video, video_type: :review
      )
    end

    it 'should increase total_videos value automatically' do
      assert_difference 'TeacherRecommendationVideo.count', 1 do
        assert_difference 'recommend.reload.total_videos', 1 do
          TestAfterCommit.with_commits(true) do
            subject
          end
        end
      end
    end
  end

  describe 'validation' do
    subject do
      TeacherRecommendationVideo.create!(
        teacher_recommendation_id: teacher_recommendation.id,
        video_id:                  video.id,
        video_type:                video_type
      )
    end

    let(:video) { Video.find_by(schoolyear: video_schoolyear_param) }
    let(:teacher_recommendation) do
      TeacherRecommendation.find_by(school: t_reco_school_param)
    end

    let(:video_type)             { 'review' }
    let(:t_reco_school_param)    { 'k' }
    let(:video_schoolyear_param) { 'k' }

    describe 'video_school_and_teacher_recommedation_school_must_be_same' do
      describe 'when same school' do
        it 'should create record' do
          assert_difference 'TeacherRecommendationVideo.count', 1 do
            subject
          end
        end
      end

      describe "when video's school teacher_recommendation's school are different" do
        let(:t_reco_school_param) { 'c' }
        it 'should raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
    end

    describe 'video_type' do
      %w(review preparation).each do |video_type|
        describe "with #{video_type}" do
          let(:video_type) { video_type }
          it 'should create record' do
            assert_difference 'TeacherRecommendationVideo.count', 1 do
              subject
            end
          end
        end
      end

      describe 'with invalid video_type' do
        let(:video_type) { 'INVALID' }
        it 'should raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end

      describe 'with nil video_type' do
        let(:video_type) { nil }
        it 'should raise ActiveRecord::RecordInvalid' do
          assert_raise ActiveRecord::RecordInvalid do
            subject
          end
        end
      end
    end
  end
end
