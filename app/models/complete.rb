# == Schema Information
#
# Table name: completes
#
#  id         :integer          not null, primary key
#  student_id :integer
#  video_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_completes_on_student_id  (student_id)
#  index_completes_on_video_id    (video_id)
#
# Foreign Keys
#
#  fk_rails_1b5f01055d  (video_id => videos.id)
#  fk_rails_20de40ebcc  (student_id => students.id)
#


class Complete < ActiveRecord::Base
  belongs_to :student
  belongs_to :video
end
