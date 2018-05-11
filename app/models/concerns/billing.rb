module Billing
  extend ActiveSupport::Concern

  def billing_datum(beginning_of_month)
    orders_to_bill = self.orders.ordereds_and_settleds.where(created_at: [beginning_of_month..beginning_of_month.end_of_month])
    {
      full_name: self.full_name,
      total_point_by_person: orders_to_bill.map(&:total_point).map(&:to_i).sum,
      orders: orders_to_bill.each_with_object([]) do |order, orders_arrray|
        orders_arrray << {
          total_point: order.total_point,
          orderd_at: order.created_at,
          category: (
            case order.category
            when 'question'
              '質問添削'
            when 'textbook'
              '公式問題集/授業テキスト購入'
            else # 家庭教師派遣などの商品が増えたら要改修
              ''
            end + case order.state
            when 'ordered'
              '（処理中）'
            when 'settled'
              ''
            when 'canceld'
              '（キャンセルまたは返ポイント）'
            end
          )
        }
      end
    }
  end
end
