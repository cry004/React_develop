require "test_helper"

class LearningTest < ActiveSupport::TestCase
  def learning
    @learning ||= Learning.new(student_id:   1,
                               sub_unit_id:  1,
                               status:       :scheduled,
                               period_id:    1)
  end

  def test_valid
    assert learning.valid?
  end
end
