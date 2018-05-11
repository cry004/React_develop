# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  name         :string
#  point        :integer
#  category     :string
#  state        :string
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_name :string
#  subject_type :string
#  school       :string
#  year         :string
#  photo_id     :integer
#  url          :string
#

class Product < ActiveRecord::Base
  # define default scope
  ## none

  # define constants
  CATEGORIES = %w(question textbook textbook_set workbook).freeze

  # define scopes
  scope :onsales,       -> { where(state: 'onsale') }
  scope :shipping_fees, -> { where(category: 'shipping_fee') }
  scope :textbooks,     -> { where(category: 'textbook') }
  scope :textbook_sets, -> { where(category: 'textbook_set') }
  scope :english,       -> { where(subject_name: 'english') }
  scope :mathematics,   -> { where(subject_name: 'mathematics') }
  scope :science,       -> { where(subject_name: 'science') }
  scope :geography,     -> { where(subject_name: 'geography') }
  scope :history,       -> { where(subject_name: 'history') }
  scope :civics,        -> { where(subject_name: 'civics') }
  scope :social_studies, -> { where(subject_name: 'social_studies') }
  scope :english_grammar, -> { where(subject_type: 'english_grammar') }
  scope :mathematics_1, -> { where(subject_type: 'mathematics_1') }
  scope :mathematics_a, -> { where(subject_type: 'mathematics_a') }
  scope :mathematics_2, -> { where(subject_type: 'mathematics_2') }
  scope :mathematics_b, -> { where(subject_type: 'mathematics_b') }
  scope :regular,       -> { where(subject_type: 'regular') }
  scope :exam,          -> { where(subject_type: 'exam') }
  scope :c1,            -> { where(school: 'c').where(year: '1') }
  scope :c2,            -> { where(school: 'c').where(year: '2') }
  scope :c3,            -> { where(school: 'c').where(year: '3') }
  scope :k,             -> { where(school: 'k') }
  scope :workbooks,     -> { where(category: 'workbook') }

  # define macros related to attr_*
  ## none

  # define assosiations
  has_one :product_photo, dependent: :destroy
  has_many :product_relations, foreign_key: 'product_id', dependent: :destroy
  has_many :relational_products, through: :product_relations,
                                 source: :relational_product
  has_many :cart_items

  # define validations
  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  # define callbacks
  ## none

  # define state_machine
  state_machine :state, initial: :standby do
    event :release do
      transition standby: :onsale
    end
    event :discontinue do
      transition onsale: :discontinued
    end
  end

  # define class methods
  class << self
    def find_shipping_fee(products)
      shipping_fees.where(point: shipping_fee(products)).first
    end

    def shipping_fee(products)
      if products.map(&:point).sum >= 5000
        0
      elsif products.count == 1
        450
      else
        400
      end
    end
  end

  def self.question_points
    find_by(category: 'question')&.point
  end

  # ショートカット
  def schoolyear
    school.to_s + year.to_s
  end

  def human_schoolyear
    Settings.schoolyear_name[schoolyear]
  end

  def human_subject_type
    Settings.subject_type_name[subject_type]
  end

  def human_subject
    Settings.subject_name[subject_name]
  end

  def year_and_subject
    school + year + '_' + subject_full_name
  end

  def subject_full_name
    "#{subject_name}_#{subject_type}"
  end
end
