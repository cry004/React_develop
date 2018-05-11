# == Schema Information
#
# Table name: devices
#
#  id            :integer          not null, primary key
#  pushable_type :string           not null
#  pushable_id   :integer          not null
#  token         :string           not null
#  os            :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  endpoint_arn  :string
#
# Indexes
#
#  index_devices_on_pushable_type_and_pushable_id  (pushable_type,pushable_id)
#  index_devices_on_token_and_os                   (token,os) UNIQUE
#

class Device < ActiveRecord::Base
  DEFAULT_BADGE_NUMBER = 1
  SILENT_FLAG_ENABLE = true
  DEFAULT_NOTIFY_SOUND = 'push_sound.caf'

  belongs_to :pushable, polymorphic: true

  validates :pushable_type, presence: true
  validates :pushable_id,   presence: true
  validates :token, presence: true
  validates :token, uniqueness: { scope: :os }
  validates :os, presence: true
  validates :os, inclusion: { in: %w(ios android) }

  scope :owns, lambda { |os:, token:, student:|
    where(os:       os,
          token:    token,
          pushable: student)
  }

  scope :others, lambda { |os:, token:, student:|
    where(os:            os,
          token:         token,
          pushable_type: student.class.to_s)
    .where.not(pushable_id: student.id)
  }

  scope :search_by_student_ids, lambda { |student_ids|
    where(pushable_type: Student.name, pushable_id: pushable_ids)
  }

  before_destroy :delete_endpoint_arn
  before_save :set_endpoint_arn
  before_save :subscribe_whole_student_notification

  def self.sns_client
    unless Rails.env.in?(%w(development test))
      http_proxy = "https://#{ENV['PROXY_ADDR']}:#{ENV['PROXY_PORT']}"
    end

    @sns_client ||=
      Aws::SNS::Client.new(
        region:            ENV['AWS_DEFAULT_REGION'],
        access_key_id:     ENV['AWS_ACCESS_KEY_ID_sns_full_access_user'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY_sns_full_access_user'],
        http_proxy:        http_proxy
      )
  end

  def self.notify(post, type = nil)
    return if Rails.env.development?
    post.question.student.devices.each do |device|
      device.push(sns_client, DEFAULT_BADGE_NUMBER, post, type, nil, DEFAULT_NOTIFY_SOUND)
    end
  end

  def self.notify_silent(student)
    return if Rails.env.development?
    unread_notifications_count = student.unread_notification_num
    student.devices.each do |device|
      device.push(sns_client, unread_notifications_count, nil, nil, SILENT_FLAG_ENABLE)
    end
  end

  def self.push_for_specific_students(message, news_id, student_ids: [])
    message = notification_message_json(nil, nil, message, news_id, DEFAULT_BADGE_NUMBER, nil, DEFAULT_NOTIFY_SOUND)
    push_for_specific_devices_of(pushable_ids: student_ids, message: message, news_id: news_id)
  end

  def self.push_for_specific_devices_of(pushable_ids: [], message: self.notification_message_json, news_id: nil)
    # Subscribe end_point to topic
    endpoint_arns = self.search_by_student_ids(pushable_ids).pluck(:endpoint_arn)
    topic = topic_arn(news_id)
    endpoint_arns.each do |endpoint_arn|
      sns_client.subscribe(topic_arn: topic,
                           protocol:  'application',
                           endpoint:  endpoint_arn)
    end
    # Publish to the topic
    sns_client.publish(target_arn: topic,
                       message:    message,
                       message_structure: 'json')
  rescue => error
    logger.fatal([error.class, error.message, error.backtrace])
  ensure
    # Delete the topic
    # sns_client.delete_topic(topic_arn: topic)
  end

  def self.bulk_notify(message, topic_arn, news_id)
    sns_client.publish(target_arn:        topic_arn,
                       message:           notification_message_json(nil, nil, message, news_id, DEFAULT_BADGE_NUMBER, nil, DEFAULT_NOTIFY_SOUND),
                       message_structure: 'json')
  rescue => error
    logger.fatal([error.class, error.message, error.backtrace])
  end

  def self.notification_message_json(post = nil, type = nil, message = nil, news_id = nil, badge_number = nil, silent_flag = nil, sound = nil)
    if silent_flag
      message = nil
    else
      setting   = Settings.push_notification_message
      message ||= (type == 'post_accepted') ? setting.post_accepted : setting.default
    end
    custom_payload = { news_id: news_id, question_id: post&.question_id }
    apns_payload = { aps: { alert: message, sound: sound, badge: badge_number, 'content-available': silent_flag } }
                   .merge(custom_payload).to_json
    fcm_payload  = { notification: { text: message }, data: custom_payload }.to_json
    { default: message, APNS: apns_payload, GCM: fcm_payload }.to_json
  end

  # Return or create topic_arn
  def self.topic_arn(news_id = nil)
    name = "tmp_topic_#{Rails.env}_#{news_id}"
    @topic_arn = sns_client.create_topic(name: name).topic_arn
  end

  def set_endpoint_arn
    setting = Settings.aws_sns
    arn = if Rails.env.api_develop? && self.pushable.try(:username) == 'push_test'
            setting.ios_development_arn # for test of iOS developers
          else
            setting.send("#{self.os}_arn")
          end
    raise 'InvalidDeviceOSError' if arn.nil?
    self.endpoint_arn = self.class.sns_client
                            .create_platform_endpoint(platform_application_arn: arn,
                                                      token: self.token)
                            .endpoint_arn
  rescue => error
    logger.fatal([error.class, error.message, error.backtrace])
  ensure
    true
  end

  def push(client, badge_number, post = nil, type = nil, silent_flag = nil, sound=nil)
    set_endpoint_arn unless endpoint_arn

    # Try changing Enabled false to true
    endpoint_attributes = client.get_endpoint_attributes(endpoint_arn: endpoint_arn)
    unless endpoint_attributes.attributes['Enabled'] == 'true'
      client.set_endpoint_attributes(endpoint_arn: endpoint_arn,
                                     attributes: { 'Enabled' => 'true' })
    end

    message = Device.notification_message_json(post, type, nil, nil, badge_number, silent_flag, sound)
    client.publish(target_arn: endpoint_arn,
                   message:    message,
                   message_structure: 'json')
  rescue => error
    logger.fatal([error.class, error.message, error.backtrace])
  end

  private

  def delete_endpoint_arn
    self.class.sns_client.delete_endpoint(endpoint_arn: endpoint_arn)
  rescue => error
    logger.fatal([error.class, error.message, error.backtrace])
  ensure
    true
  end

  def subscribe_whole_student_notification
    subscribe_topic_arn(Settings.whole_student_notification_topic)
  end

  def subscribe_topic_arn(topic_arn)
    return if endpoint_arn.blank?
    self.class.sns_client.subscribe(topic_arn: topic_arn,
                                    protocol:  'application',
                                    endpoint:  endpoint_arn)
  end
end
