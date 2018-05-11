require "test_helper"

class CurriculumTest < ActiveSupport::TestCase
  def curriculum
    @curriculum ||= Curriculum.new(agreement_dow: '01')
  end

  def test_valid
    assert curriculum.valid?
  end
end
