# == Schema Information
#
# Table name: spent_point_histories
#
#  id             :integer          not null, primary key
#  student_id     :integer
#  year_and_month :integer
#  spent_point    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  monthly_point  :integer
#
# Indexes
#
#  index_spent_point_histories_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_324429afbc  (student_id => students.id)
#


class SpentPointHistory < ActiveRecord::Base
  belongs_to :student

  validates :spent_point, presence: true
  validates :monthly_point, presence: true
  validates :year_and_month, presence: true
  validates :student, presence: true

  # @author tamakoshi
  # @since 20150617
  # 月末締めのポイント更新処理
  def self.execute(student)
    current_month = student.current_month
    SpentPointHistory.transaction do
      next_month = increase_current_month(current_month)
      point_update_history = SpentPointHistory.create!(
        student: student,
        spent_point: student.orders.settled_current_month_order(current_month, next_month).map(&:total_point).sum,
        monthly_point: student.current_monthly_point,
        year_and_month: current_month
        )
      student.update_attributes!(
        spent_point: 0,
        current_month: next_month,
        current_monthly_point: student.following_monthly_point
        )
    end
  end

  private

  # @author hasumi
  # @since 20150522
  # YYYYMM形式の月をひとつ進める
  def self.increase_current_month(current_month)
    year = current_month.to_s[0..3].to_i
    month = current_month.to_s[4..5].to_i
    if month < 12
      month += 1
    else
      year += 1
      month = 1
    end
    (year * 100) + month
  end
end
