# == Schema Information
#
# Table name: video_worksheets
#
#  id           :integer          not null, primary key
#  video_id     :integer          not null
#  worksheet_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_video_worksheets_on_video_id      (video_id)
#  index_video_worksheets_on_worksheet_id  (worksheet_id)
#
# Foreign Keys
#
#  fk_rails_2625f4c2dc  (worksheet_id => worksheets.id)
#  fk_rails_74e873b19f  (video_id => videos.id)
#

class VideoWorksheet < ActiveRecord::Base
  belongs_to   :video
  belongs_to   :worksheet

  belongs_to :ensyu_answer_worksheet, -> { where(category: :ensyu, type: :answer) },
                                      class_name: Worksheet.name,
                                      foreign_key: :worksheet_id

  belongs_to :syutoku_answer_worksheet, -> { where(category: :syutoku, type: :answer) },
                                        class_name: Worksheet.name,
                                        foreign_key: :worksheet_id

  validates :video_id,     presence: true
  validates :worksheet_id, presence: true,
                           uniqueness: { scope: :video_id }
end
