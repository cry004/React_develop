require "test_helper"

class LearningReportTest < ActiveSupport::TestCase
  def learning_report
    @learning_report ||= LearningReport.new
  end

  def test_valid
    assert learning_report.valid?
  end
end
