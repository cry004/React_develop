# == Schema Information
#
# Table name: video_viewings
#
#  id                     :integer          not null, primary key
#  student_id             :integer          not null
#  video_id               :integer          not null
#  viewed_time            :integer          not null
#  watched                :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  experience_point       :integer          default(0), not null
#  unit_trophy_flag       :boolean          default(FALSE), not null
#  schoolbook_trophy_flag :boolean          default(FALSE), not null
#
# Indexes
#
#  index_video_viewings_on_student_id  (student_id)
#  index_video_viewings_on_video_id    (video_id)
#
# Foreign Keys
#
#  fk_rails_343259958c  (video_id => videos.id)
#  fk_rails_79b508a5ff  (student_id => students.id)
#

class VideoViewing < ActiveRecord::Base
  WATCHED_THRESHOLD = 5.minutes
  attr_accessor :schoolbook, :unit_title, :video_ids_current_watched

  include LearningProgressHelper

  belongs_to :video,   required: true
  belongs_to :student, required: true

  scope :date_range, -> (from, to) { where(created_at: from...to) }
  scope :belong_to_student, -> (student) { where(student: student) }
  scope :group_by_pref_code,     -> { joins(:student).merge(Student.group_by_pref_code) }
  scope :group_by_student_id,    -> { group(:student_id) }
  scope :group_by_class_id,      -> { joins(:student).merge(Student.group_by_class_id) }
  scope :group_by_class_pref_code, -> { joins(:student).merge(Student.group_by_class_pref_code) }
  scope :order_sum_viewed_time,  -> { order('sum_viewed_time DESC') }
  scope :ranking_countable,      -> { joins(:student).merge(Student.rankable) }
  scope :sum_viewed_time,        -> { sum(:viewed_time) }
  scope :classroom_ranking_countable, -> { joins(:student).merge(Student.classroom_rankable) }
  scope :schoolhouse_ranking_countable, -> { joins(:student).merge(Student.schoolhouse_rankable) }
  scope :watched,                -> { where(watched: true) }

  validates :viewed_time, presence:     true,
                          numericality: { only_integer: true }

  before_save :set_watched
  before_save :set_experience_point_video
  before_save :set_experience_point_unit
  after_commit :set_level
  after_commit :set_trophy

  counter_culture :video,   column_name:  :view_count
  counter_culture :student, column_name:  :experience_point,
                            delta_column: :experience_point
  counter_culture :student, column_name:  :viewing_time,
                            delta_column: :viewed_time

  private

  def set_watched
    time           = viewed_time
    video_duration = video.duration
    self.watched = (WATCHED_THRESHOLD <= time || video_duration <= time).to_s
  end

  def set_experience_point_video
    return unless watched
    return self.experience_point += 50 if re_viewing?
    experience_point = case video.subject.type
                       when 'high-level' then 300
                       when 'standard'   then 200
                       else                   100
                       end
    self.experience_point += experience_point
  end

  def set_level
    total_exp = student.reload.experience_point
    level     = Level.where('experience_point <= ?', total_exp).maximum(:level)
    student.update(level: level)
  end

  def set_trophy
    return unless watched
    return unless unit_trophy_flag
    student.reload.trophies_count
    student.increment!(:trophies_count, 1)
  end

  def re_viewing?
    self.class.exists?(student: student, video: video, watched: true)
  end

  def set_experience_point_unit
    return unless watched
    @schoolbook      = find_schoolbook_with_video(video, student)
    return unless @schoolbook
    video_id_watched = VideoViewing.belong_to_student(student).watched.uniq.pluck(:video_id)

    unit        = belonging_to_unit(@schoolbook, video)
    @unit_title = unit['title'] + unit['title_description']
    unit_video_ids    = get_unit_video_ids(unit)
    unit_video_count  = unit_video_ids.count
    watched_unit_flag = unit_video_count == (video_id_watched & unit_video_ids).count
    return if watched_unit_flag

    @video_ids_current_watched = video_id_watched | [video_id]
    watched_unit(unit_video_count, unit_video_ids, @video_ids_current_watched)
    watched_schoolbook(@schoolbook, @video_ids_current_watched)
  end

  def watched_unit(unit_video_count, unit_video_ids, video_ids_current_watched)
    self.unit_trophy_flag = unit_video_count == (video_ids_current_watched & unit_video_ids).count
    self.experience_point += 1000 if self.unit_trophy_flag
  end

  def watched_schoolbook(schoolbook, video_ids_current_watched)
    schoolbook_video_ids = schoolbook.video_ids
    self.schoolbook_trophy_flag = schoolbook_video_ids.count == (video_ids_current_watched & schoolbook_video_ids).count
    self.experience_point += 2000 if self.schoolbook_trophy_flag
  end
end
