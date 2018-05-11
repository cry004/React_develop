# == Schema Information
#
# Table name: video_tags
#
#  id         :integer          not null, primary key
#  video_id   :integer          not null
#  name       :string           not null
#  values     :jsonb            not null
#  priority   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_video_tags_on_priority           (priority)
#  index_video_tags_on_values             (values)
#  index_video_tags_on_video_id           (video_id)
#  index_video_tags_on_video_id_and_name  (video_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_fcdb957abf  (video_id => videos.id)
#

class VideoTag < ActiveRecord::Base
  belongs_to :video, required: true

  validates :name,     presence:   true,
                       uniqueness: { scope: %i(video_id) }
  validates :values,   presence:   true
  validates :priority, presence:   true
end
