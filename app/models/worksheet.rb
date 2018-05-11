# == Schema Information
#
# Table name: worksheets
#
#  id         :integer          not null, primary key
#  category   :string           not null
#  type       :string           not null
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_worksheets_on_url  (url) UNIQUE
#

class Worksheet < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  # TODO: Add lessontext, checktest and practice to CATEGORIES
  CATEGORIES = %w(ensyu syutoku)
  TYPES      = %w(question answer)

  # HACK: Move a constant to an appropriate place
  S3_HOST = 'https://s3-ap-northeast-1.amazonaws.com'

  module BUCKETS
    ENSYU = 'my-try-ensyu-ans'
    SYUTOKU = 'my-try-syutoku-ans'

    def self.all
      self.constants.map{|name| self.const_get(name) }
    end
  end

  has_many :video_worksheet
  has_many :video, through: :video_worksheet

  validates :category, presence: true,
                       inclusion:  { in: CATEGORIES }

  validates :type, presence: true,
                   inclusion: { in: TYPES }

  validates :url, presence: true,
                  uniqueness: true

  validate :ensyu_and_syutoku_can_not_be_combined_with_question
  validate :url_must_be_in_the_expected_format

  def ensyu_and_syutoku_can_not_be_combined_with_question
  # HACK: Refactor error messages in appropriate wording and place
    error_msg = "category: '#{category}' and type: 'question' can not be combined"

    # HACK: Refactor if statements
    errors.add(:category, error_msg) if category.in?(%w(ensyu syutoku)) && type == 'question'
  end

  def url_must_be_in_the_expected_format
    # HACK: Refactor error messages in appropriate wording and place
    error_msg = " doesn't looks like in the expected format"
    errors.add(:url, error_msg) unless is_expected_url_format
  end

  private

  def is_expected_url_format
    # NOTE: "#{host}"/#{bucket_name}/#{category}#{type_modifier}/#{school_year}/#{subject_name}/(#{sub_category})/#{filename}#{file_suffix}.pdf"
    expected_format = %r(\A#{S3_HOST}/#{bucket_name}/#{category}#{type_modifier}/[\w\-_]+/[\w\-_]+/[\w\-_]*?/?[\w\-_]+#{file_suffix}\.pdf\z)
    expected_format === url
  end

  def bucket_name
    bucket_prefix + category_modifier + type_modifier
  end

  def bucket_prefix
    case category
    when *%w(ensyu syutoku) then 'my-try'
    else 'try-it'
    end
  end

  def category_modifier
    "-#{category}"
  end

  def type_modifier
    case type
    when 'question' then ''
    else '-ans'
    end
  end

  def file_suffix
    "#{category}#{type_modifier.tr('-', '_')}"
  end

end
