require "test_helper"

class YoutubeVideoTest < ActiveSupport::TestCase
  def youtube_video
    @youtube_video ||= YoutubeVideo.new
  end

  def test_valid
    assert youtube_video.valid?
  end
end
