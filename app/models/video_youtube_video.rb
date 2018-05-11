# == Schema Information
#
# Table name: video_youtube_videos
#
#  id               :integer          not null, primary key
#  video_id         :integer          not null
#  youtube_video_id :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_video_youtube_videos_on_video_id          (video_id)
#  index_video_youtube_videos_on_youtube_video_id  (youtube_video_id)
#
# Foreign Keys
#
#  fk_rails_14b9f5226f  (video_id => videos.id)
#  fk_rails_fa264948bc  (youtube_video_id => youtube_videos.id)
#


class VideoYoutubeVideo < ActiveRecord::Base
  belongs_to :video
  belongs_to :youtube_video
end
