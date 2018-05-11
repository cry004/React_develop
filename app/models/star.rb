# == Schema Information
#
# Table name: stars
#
#  id         :integer          not null, primary key
#  student_id :integer
#  video_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_stars_on_student_id  (student_id)
#  index_stars_on_video_id    (video_id)
#
# Foreign Keys
#
#  fk_rails_1d5b2ee161  (video_id => videos.id)
#  fk_rails_a19056931d  (student_id => students.id)
#


class Star < ActiveRecord::Base
  belongs_to :student, required: true
  belongs_to :video, required: true

  scope :find_old_stars, ->(star_created_at) { where('created_at < ?', star_created_at) if star_created_at }
end
