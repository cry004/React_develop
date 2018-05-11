require "test_helper"

class ENaviSubUnitTest < ActiveSupport::TestCase
  def e_navi_sub_unit
    @e_navi_sub_unit ||= ENaviSubUnit.new
  end

  def test_valid
    assert e_navi_sub_unit.valid?
  end
end
