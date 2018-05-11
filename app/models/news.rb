# == Schema Information
#
# Table name: news
#
#  id               :integer          not null, primary key
#  title            :string           not null
#  content          :text             not null
#  photo_id         :integer
#  published_at     :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  message          :string           not null
#  prefecture_codes :jsonb
#  member_types     :jsonb
#  gknn_cds         :jsonb
#
# Indexes
#
#  index_news_on_photo_id  (photo_id)
#
# Foreign Keys
#
#  fk_rails_feb653b0f1  (photo_id => photos.id)
#

class News < ActiveRecord::Base
  MIN_MESSAGE_LENGTH = 1
  MAX_MESSAGE_LENGTH = 250
  MIN_TITLE_LENGTH   = 1
  MAX_TITLE_LENGTH   = 250
  MIN_CONTENT_LENGTH = 1
  MAX_CONTENT_LENGTH = 4000
  PREFECTURE_CODES   = JpPrefecture::Prefecture.all.map(&:code)
  MEMBER_TYPES       = ['tryit', 'fist']
  GKNN_CDS           = GknnCd::Map.keys

  PUSH_TOPIC = Settings.whole_student_notification_topic

  belongs_to :news_photo, foreign_key: :photo_id, dependent: :destroy
  has_many :news_students, dependent: :destroy

  validates :message, presence: true,
                      length:   { in: MIN_MESSAGE_LENGTH..MAX_MESSAGE_LENGTH }
  validates :title,   presence: true,
                      length:   { in: MIN_TITLE_LENGTH..MAX_TITLE_LENGTH }
  validates :content, presence: true,
                      length:   { in: MIN_CONTENT_LENGTH..MAX_CONTENT_LENGTH }
  validate :prefecture_codes_validation
  validate :member_types_validation
  validate :gknn_cds_validation
  validates :published_at, presence: true

  validate :published_at_cannot_be_in_the_past

  scope :published,       -> { where('published_at <= ?', Time.current) }
  scope :select_for_list, -> { select(:id, :title, :published_at, :unread) }
  scope :recent,          -> { order(published_at: :desc) }
  scope :older, lambda { |published_at|
    where('published_at < ?', published_at) if published_at
  }

  before_destroy :remove_file

  def publish
    fail Exceptions::NewsPublicationError unless publishable?
    segment = { prefecture_codes: prefecture_codes,
                member_types:     member_types,
                gknn_cds:         gknn_cds }
    student_ids = Search::Student.new(segment)
                                 .search_by_segment
                                 .news_deliverable
                                 .pluck(:id)
    columns = %i(news_id student_id)
    values  = [id].product(student_ids)
    NewsStudent.import(columns, values, validate: false)
    if segment.values.any?(&:present?)
      Device.push_for_specific_students(message, id, student_ids: student_ids)
    else
      Device.bulk_notify(message, PUSH_TOPIC, id)
    end
  end

  ### for Typus ###
  delegate :image,           to: :news_photo, allow_nil: true
  delegate :image_thumbnail, to: :news_photo, allow_nil: true

  def human_published?
    I18n.t("activerecord.attributes.news.published?.#{published?}")
  end

  def content_photo_uids
    doc    = Nokogiri::HTML(content)
    images = doc.css('img').map { |node| node['src'] }
    host   = unless Rails.env.test? || Rails.env.development?
      "https://#{ENV['S3_BUCKET_NAME_dragon_fly']}.s3.amazonaws.com/"
    else
      '/dragonfly/ckeditor/'
    end
    images.each{ |image| image.slice!(host) }
  end

  def remove_file
    news_content_photos = NewsContentPhoto.where(image_uid: content_photo_uids)
    news_content_photos.destroy_all
  end

  private

  def published_at_cannot_be_in_the_past
    return true if published_at&.future?
    errors.add(:published_at, :invalid)
  end

  def prefecture_codes_validation
    return true unless prefecture_codes.present?
    unless prefecture_codes.all? { |code| code.to_i.in?(PREFECTURE_CODES) }
      errors.add(:prefecture_codes, :invalid)
    end
  end

  def member_types_validation
    return true unless member_types.present?
    unless member_types.all? { |member_type| member_type.in?(MEMBER_TYPES) }
      errors.add(:member_types, :invalid)
    end
  end

  def gknn_cds_validation
    return true unless gknn_cds.present?
    unless gknn_cds.all? { |gknn_cd| gknn_cd.in?(GKNN_CDS) }
      errors.add(:gknn_cds, :invalid)
    end
  end

  def published?
    news_students.exists?
  end

  def unpublished?
    !published?
  end

  def publishable?
    published_at <= Time.current && unpublished?
  end
end
