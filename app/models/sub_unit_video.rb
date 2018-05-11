# == Schema Information
#
# Table name: sub_unit_videos
#
#  id          :integer          not null, primary key
#  sub_unit_id :integer
#  video_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_sub_unit_videos_on_sub_unit_id  (sub_unit_id)
#  index_sub_unit_videos_on_video_id     (video_id)
#


class SubUnitVideo < ActiveRecord::Base
  belongs_to :sub_unit
  belongs_to :video
end
