require 'test_helper'
include ApplicationHelper

class ApplicationHelperTest < ActiveSupport::TestCase
  describe "test round_off(position_time)" do
    it "引数が、0~4の時は1を返す" do
      position_times = 0..4
      position_times.each do |position_time|
        assert_equal round_off(position_time), 1
      end
    end
    it "引数が5以上の時は、引数の数以下の整数で引数の数に最も近い5の倍数を返す" do
      position_times = 5..25
      position_times.each do |position_time|
        expect_num = (position_time / 5) * 5
        assert_equal round_off(position_time), expect_num
      end
    end
  end
end
