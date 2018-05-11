require 'test_helper'

class TeacherRecommendationTest < ActiveSupport::TestCase
  describe '.notifiable' do
    subject { TeacherRecommendation.notifiable }

    it 'should return the latest recommendations grouped by teacher id' do
      assert(subject.all? { |t_reco| t_reco.state == 'notifiable' })
    end
  end

  describe '.included_requirement' do
    subject { TeacherRecommendation.included_requirement }

    let(:find_teacher_blk) { ->(value) { value.to_sym == :teacher } }
    let(:find_videos_blk) do
      ->(value) { value.is_a?(Hash) && value.keys.first.to_sym == :videos }
    end
    let(:find_stars_and_completes_blk) do
      ->(value) do
        value.is_a?(Hash) && (value.keys - %i(stars completes)).blank?
      end
    end

    it 'should includes videos, teacher and more' do
      assert(subject.includes_values.any?(&find_teacher_blk))

      videos = subject.includes_values.find(&find_videos_blk)[:videos]
      assert(videos)

      stars_and_completes = videos.find(&find_stars_and_completes_blk)

      assert(stars_and_completes)
      assert_equal(:student, stars_and_completes[:stars])
      assert_equal(:student, stars_and_completes[:completes])
      assert(videos.include?(:subject))
      assert(videos.include?(:video_title_image))
      assert(videos.include?(:video_subtitle_image))
    end
  end

  describe '#hide' do
    before do
      @teacher_recommendation = TeacherRecommendation.find_by(state: state_param)
    end
    subject { @teacher_recommendation.hide }
    let(:state_param) { 'notifiable' }

    it 'state should be not_notifiable' do
      subject
      assert_equal 'not_notifiable', @teacher_recommendation.state
    end

    describe 'when state is not_notifiable' do
      it 'state should not be changed' do
        subject
        assert_equal 'not_notifiable', @teacher_recommendation.state
      end
    end
  end

  describe '#update_all_except_self_not_notifiable' do
    subject { TeacherRecommendation.create(teacher: teacher, student: student, school: 'c') }
    let(:student) { Student.first }
    let(:teacher) { Teacher.first }

    it 'notifiable state teacher_recommendation count should be one' do
      last_teacher_recommendation =
        TeacherRecommendation.find_by(
          teacher: teacher,
          student: student,
          state: 'notifiable',
          school: 'c'
        )
      subject

      last_teacher_recommendation.reload
      assert_equal('not_notifiable', last_teacher_recommendation.state)
      assert_equal(1,
        TeacherRecommendation.where(student: student, teacher: teacher, school: 'c')
                             .notifiable
                             .count)
    end
  end

  describe '.older_records' do
    subject { TeacherRecommendation.older_records(id_param) }
    let(:id_param) { TeacherRecommendation.last.id - 5 }

    it 'should return older records' do
      base_object = TeacherRecommendation.find(id_param)
      assert(subject.all? { |d| d.created_at < base_object.created_at })
      assert(subject.all? { |d| d.id < base_object.id })
    end
  end
end
