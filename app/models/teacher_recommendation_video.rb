# == Schema Information
#
# Table name: teacher_recommendation_videos
#
#  id                        :integer          not null, primary key
#  teacher_recommendation_id :integer
#  video_id                  :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  video_type                :string
#
# Indexes
#
#  index_teacher_recommend_videos_on_teacher_recommendation_id  (teacher_recommendation_id)
#  index_teacher_recommendation_videos_on_video_id              (video_id)
#


class TeacherRecommendationVideo < ActiveRecord::Base
  belongs_to :teacher_recommendation
  belongs_to :video

  validates :video_type, inclusion: { in: %w(review preparation) }
  validate :video_school_and_teacher_recommedation_school_must_be_same

  counter_culture :teacher_recommendation, column_name: :total_videos

  private

  # @author tamakoshi
  # @since 20160218
  def video_school_and_teacher_recommedation_school_must_be_same
    teacher_recommendation_school = teacher_recommendation.school
    video_school = video.schoolyear.first
    unless teacher_recommendation_school == video_school
      errors.add(:video, ' must be same school as teacher_recommendation school')
    end
  end
end
