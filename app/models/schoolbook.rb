# == Schema Information
#
# Table name: schoolbooks
#
#  id         :integer          not null, primary key
#  sort       :integer
#  year       :string
#  name       :string
#  subject_id :integer
#  units      :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company    :string
#
# Indexes
#
#  index_schoolbooks_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  fk_rails_877f7d342f  (subject_id => subjects.id)
#

class Schoolbook < ActiveRecord::Base
  extend SubjectHelper

  belongs_to :subject

  scope :schoolbooks_for_subjects, lambda { |student, school_year|
    subjects = student.schoolbooks['info'][school_year]
    ids      = subjects.map { |_name, values| values['id'] }
    includes(:subject).where(id: ids)
  }

  scope :configurables, lambda {
    subjects = Subject.available_subjects('c', 'regular')
    joins(:subject).where(year: %w(c1 c2 c3)).merge(subjects).includes(:subject)
  }

  # @author tamakoshi
  # @since 20150127
  def video_ids
    units.flat_map{ |unit|unit["videos"].map{ |video| video["id"] } } if units
  end

  # @author tamakoshi
  # @since 20150210
  # unitsに含まれる動画の配列をunitsの順番通りに返す。
  def videos
    videos = Video.includes_videos.find(video_ids)
    Video.sort_by_units_order(videos, video_ids)
  end

  def videos_for_subject_of_course
    videos = Video.includes(:video_viewings_with_current_student).find(video_ids)
    Video.sort_by_units_order(videos, video_ids)
  end

  def self.find_and_sort_by_order(ids)
    schoolbooks = self.where(id: ids)
    array = []
    schoolbooks.each { |v| array[ids.index(v.id)] = v }
    array
  end

  def next_video_ids(video_id)
    current_video_index = video_ids.index(video_id)
    current_video_index.present? ? video_ids[(current_video_index + 1)..-1].first(5) : []
  end

  def previous_video_ids(video_id)
    current_video_index = video_ids.index(video_id)
    current_video_index.present? ? video_ids[0...current_video_index].last(5) : []
  end

  def has_video?(video_id)
    video_ids.include? video_id
  end

  def unit_video_ids(video_id)
    unit = units.select { |unit| unit["videos"].select {|video|video["id"] == video_id }.present? }.first
    unit["videos"].map { |video| video["id"] }
  end

  def self.filter_schoolyears(schoolyears, subject_name)
    return [] if subject_name.in?(%w(geography history civics japanese))
    schoolyears
  end

  private_class_method :filter_schoolyears

end
