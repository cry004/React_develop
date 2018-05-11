# == Schema Information
#
# Table name: credits
#
#  id              :integer          not null, primary key
#  parent_id       :integer
#  reserved_amount :integer
#  executed_amount :integer
#  state           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  student_id      :integer
#  order_id        :integer
#
# Indexes
#
#  index_credits_on_order_id    (order_id)
#  index_credits_on_parent_id   (parent_id)
#  index_credits_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_4f77f3fdf6  (parent_id => parents.id)
#  fk_rails_8892dfb1c3  (order_id => orders.id)
#  fk_rails_ce03026763  (student_id => students.id)
#


class Credit < ActiveRecord::Base
  belongs_to :parent
  belongs_to :student
  has_many :sbps_logs
  belongs_to :order

  state_machine :state, initial: :requested do
    # 与信獲得に失敗した場合、紐づくorderもfailedにする。
    # ただし、問題集購入与信以外はorderが紐付かないため, nilの場合は何もしない。
    after_transition :on => :failure do |credit, transition|
      credit.order.try(:failure)
    end

    event :reserve do
      transition :requested => :reserved
    end
    event :execute do
      transition :reserved => :executed
    end
    event :cancel do
      transition :reserved => :canceled
    end
    event :failure do
      transition [:requested, :reserved] => :failed
    end
  end

  def self.reserve(params)
    credit = self.create(parent: params[:parent], reserved_amount: params[:amount], student: params[:student], order: params[:order])
    sbps_credit = SBPS::Credit.new
    sbps_credit.parent = params[:parent]
    params[:credit] = credit
    if results = sbps_credit.request_credit(params)
      params[:sps_transaction_id] = results[:sps_transaction_id]
      sbps_credit.reset_xml
      if sbps_credit.confirm_credit(params)
        credit.reserve
      else
        credit.failure
        return false
      end
    else
      credit.failure
      return false
    end
  end
end
