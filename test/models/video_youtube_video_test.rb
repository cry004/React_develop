require "test_helper"

class VideoYoutubeVideoTest < ActiveSupport::TestCase
  def video_youtube_video
    @video_youtube_video ||= VideoYoutubeVideo.new
  end

  def test_valid
    assert video_youtube_video.valid?
  end
end
