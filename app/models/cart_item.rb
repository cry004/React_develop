# == Schema Information
#
# Table name: cart_items
#
#  id                :integer          not null, primary key
#  product_id        :integer
#  quantity          :integer
#  checkoutable_type :string
#  checkoutable_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_cart_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_681a180e84  (product_id => products.id)
#


class CartItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :checkoutable, polymorphic: true
  validates :product, presence: true
  validates :checkoutable, presence: true
  validates :quantity, numericality: {
              only_integer: true, greater_than: 0, less_than: 100
            }, presence: true

  default_scope -> { order(:product_id) }

  # @author hasumi
  # @since 2015-08-18
  def self.add_products(params)
    params[:items].each do |item|
      cart_item = CartItem.find_by(checkoutable: params[:checkoutable], product_id: item["product_id"])
      if cart_item.present?
        cart_item.update_attributes! quantity: cart_item.quantity + item["quantity"].to_i
      else
        if Product.onsales.textbooks.find_by(id: item["product_id"])
          CartItem.create! product_id: item["product_id"].to_i, quantity: item["quantity"].to_i, checkoutable: params[:checkoutable]
        end
      end
    end
    return {
      status: true,
      total_quantity: CartItem.where(checkoutable: params[:checkoutable]).sum(:quantity),
      sum: CartItem.calculate_sum(params[:checkoutable])
    }
  rescue => e
    if e.message.match('Quantityは100')
      return {
        status: false,
        message: "同一商品は99個までしかカートに入りません。カートの中身をご確認ください。"
      }
    else
      return {
        status: false,
        message: "サーバエラーが発生しました。"
      }
    end
  end

  def self.calculate_sum(checkoutable)
    CartItem.includes(:product).where(checkoutable: checkoutable).map{|item| item.quantity * item.product.point}.inject(:+)
  end

  # @author hasumi
  # @since 2015-08-19
  # 購入確定
  def self.checkout(checkoutable)
    cart_items = CartItem.where(checkoutable: checkoutable).includes(:product)
    return nil if cart_items.blank?
    order = Order.checkout(checkoutable, cart_items)
    unless ::Credit.reserve(parent: checkoutable, amount: (order.total_point * Settings.tax_rate).round, order: order)
      return false
    end
    cart_items.destroy_all
    return order
  end
end
