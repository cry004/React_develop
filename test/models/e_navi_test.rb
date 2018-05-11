require "test_helper"

class ENaviTest < ActiveSupport::TestCase
  def e_navi
    @e_navi ||= ENavi.new
  end

  def test_valid
    assert e_navi.valid?
  end
end
