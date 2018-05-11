class NewsPublicationJob < ActiveJob::Base
  queue_as :news_publisher

  rescue_from Exception do |err|
    message = <<~MSG
      [QueueName] #{self.queue_name}
      [JobName] #{self.class}
      [JobID] #{self.job_id}
      [Arguments] #{self.arguments}
      [ErrorType] #{err.inspect}
      [Backtrace]
      #{err.backtrace[0..30].join("\n")}
    MSG
    slack_notification(message)
  end

  def perform(news_id:, published_at:)
    time = Time.at(published_at)
    news = News.find_by(id: news_id, published_at: time)
    return unless news
    news.publish
  end

  private

  def slack_notification(message)
    Slack.notify_by_webhook(channel, message)
  end

  def channel
    Rails.env.teacher_production? ? 'n-production-alert' : 'n-development-alert'
  end
end
