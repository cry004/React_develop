require 'test_helper'

class WorksheetsTaskTest < ActiveSupport::TestCase
  def setup
    TryVideoWeb::Application.load_tasks
  end

  describe 'create' do
    subject { Rake::Task['worksheets:create'].invoke }

    it 'sends WorksheetsTask.execute' do
      called = false
      proc = -> () { called = true }
      TaskUtils::WorksheetsTask.stub(:execute, proc) do
        subject
      end
      assert(called)
    end
  end
end
