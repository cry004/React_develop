# == Schema Information
#
# Table name: searched_words
#
#  id         :integer          not null, primary key
#  student_id :integer          not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#
# Indexes
#
#  index_searched_words_on_student_id           (student_id)
#  index_searched_words_on_student_id_and_name  (student_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_2c2bed2853  (student_id => students.id)
#

class SearchedWord < ActiveRecord::Base
  PROHIBITED_CHAR = /[０-９]|[Ａ-Ｚ]|[ａ-ｚ]|[A-Z]|[\p{katakana}]/
  LIMITED_NUMBER  = 50

  belongs_to :student, required: true

  validates :name,  presence:   true,
                    uniqueness: { scope: :student_id }
  validates :value, presence:   true,
                    format:     { without: PROHIBITED_CHAR }

  validate :number_limitation

  before_validation :remove_excess_records
  before_validation :set_value

  private

  def number_limitation
    return true if self.class.where(student: student).size <= LIMITED_NUMBER
    errors[:base] << I18n.t('activerecord.errors.messages.too_many_records')
  end

  def remove_excess_records
    owns = self.class.where(student: student).order(updated_at: :asc)
    excess_count = (owns.size - LIMITED_NUMBER).succ
    owns.take(excess_count).each(&:delete) if 0 < excess_count
  end

  def set_value
    self.value = NKF.nkf('-XWw', name.to_s)
                    .tr('０-９Ａ-Ｚａ-ｚA-Zァ-ン', '0-9a-za-za-zぁ-ん')
  end
end
