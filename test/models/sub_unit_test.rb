require "test_helper"

class SubUnitTest < ActiveSupport::TestCase
  def sub_unit
    @sub_unit ||= SubUnit.new
  end

  def test_valid
    assert sub_unit.valid?
  end
end
