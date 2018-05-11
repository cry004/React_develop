class VideoReplaceJob < ActiveJob::Base
  queue_as :default

  def perform(video, video_file_name)
    begin
      logger.info("動画: #{video_file_name}の差し替えを行います。")
      Millvi.replace_video(video, video_file_name)
    rescue => err
      logger.fatal([err.class, err.message, err.backtrace])
    end
  end
end
