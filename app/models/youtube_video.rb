# == Schema Information
#
# Table name: youtube_videos
#
#  id          :integer          not null, primary key
#  youtube_id  :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_youtube_videos_on_youtube_id  (youtube_id) UNIQUE
#


class YoutubeVideo < ActiveRecord::Base
  has_one :video_youtube_video, dependent: :destroy
  has_one :video, through: :video_youtube_video, dependent: :destroy
end
