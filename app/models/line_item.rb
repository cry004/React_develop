# == Schema Information
#
# Table name: line_items
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  product_id      :integer
#  point           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  schoolbook_name :string
#  quantity        :integer          default(1)
#
# Indexes
#
#  index_line_items_on_order_id    (order_id)
#  index_line_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_11e15d5c6b  (product_id => products.id)
#  fk_rails_2dc2e5c22c  (order_id => orders.id)
#


class LineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :order
  validates :product, presence: true
  before_save do
    self.point = self.product.point * self.quantity
  end

  OrderCSVMap = {
    "c1_english_regular"              => 0,
    "c2_english_regular"              => 1,
    "c3_english_regular"              => 2,
    "call_english_exam_"              => 3,
    "call_english_exam_NEW HORIZON"   => 4,
    "call_english_exam_Sunshine"      => 5,
    "call_english_exam_TOTAL ENGLISH" => 6,
    "call_english_exam_NEW CROWN"     => 7,
    "call_english_exam_ONE WORLD"     => 8,
    "call_english_exam_COLUMBUS21"    => 9,
    "c1_mathematics_regular"          => 10,
    "c2_mathematics_regular"          => 11,
    "c3_mathematics_regular"          => 12,
    "call_mathematics_exam"           => 13,
    "c1_science_regular"              => 14,
    "c2_science_regular"              => 15,
    "c3_science_regular"              => 16,
    "call_science_exam"               => 17,
    "call_geography_regular"          => 18,
    "call_history_regular"            => 19,
    "call_civics_regular"             => 20,
    "call_social_studies_exam"        => 21,
    "k_english_english_grammar"       => 22,
    "k_mathematics_mathematics_1"     => 23,
    "k_mathematics_mathematics_a"     => 24,
    "k_mathematics_mathematics_2"     => 25,
    "k_mathematics_mathematics_b"     => 26
  }

  # Typus用

  def product_name
    product.name
  end

  def product_point
    product.point
  end

  def product_category
    product.category
  end

  def product_subject_name
    product.subject_name
  end

  def product_subject_type
    product.subject_type
  end

  def product_school
    product.school
  end

  def product_year
    product.year
  end

  def original_name
    if product.category == "textbook"
      if product.subject_name == "english" && product.subject_type == "exam"
        product.year_and_subject + "_" + self.order.schoolbook_name
      else
        product.year_and_subject
      end
    end
  end
end
