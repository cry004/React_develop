require 'rake'

class CreateStudentsTableJob < ActiveJob::Base
  queue_as :default

  def perform
    logger.info('students:tableのrake taskを実行開始します。')
    Rails.application.load_tasks
    Rake::Task['students:table'].invoke
  rescue => err
    logger.fatal([err.class, err.message, err.backtrace])
  end
end
