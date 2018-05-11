require 'test_helper'

class GenerateCurrentTrophiesTaskTest < ActiveSupport::TestCase
  def setup
    TryVideoWeb::Application.load_tasks
  end

  describe 'generate current trophies for students' do
    subject { Rake::Task['students:gererate_current_trophies'].invoke }
    before { Student.update_all(trophies_count: 0) } # set all students's trophies_count = 0

    it 'student has trophies' do
      subject
      assert_equal Student.first.trophies_count,  5
      assert_equal Student.second.trophies_count, 2
      assert_equal Student.third.trophies_count,  0
    end
  end
end
