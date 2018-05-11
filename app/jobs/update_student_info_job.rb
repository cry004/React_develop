require 'rake'

class UpdateStudentInfoJob < ActiveJob::Base
  queue_as :default

  def perform
    logger.info('student_infoのrake taskを実行開始します。')
    Rails.application.load_tasks
    Rake::Task['student:student_info'].invoke
  rescue => err
    logger.fatal([err.class, err.message, err.backtrace])
  end
end
