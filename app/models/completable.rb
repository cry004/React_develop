# == Schema Information
#
# Table name: completables
#
#  id         :integer          not null, primary key
#  student_id :integer
#  video_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_completables_on_student_id  (student_id)
#  index_completables_on_video_id    (video_id)
#
# Foreign Keys
#
#  fk_rails_3e6303e477  (student_id => students.id)
#  fk_rails_5b15b3e15f  (video_id => videos.id)
#


class Completable < ActiveRecord::Base
  belongs_to :student
  belongs_to :video
end
