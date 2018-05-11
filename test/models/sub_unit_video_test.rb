require "test_helper"

class SubUnitVideoTest < ActiveSupport::TestCase
  def sub_unit_video
    @sub_unit_video ||= SubUnitVideo.new
  end

  def test_valid
    assert sub_unit_video.valid?
  end
end
