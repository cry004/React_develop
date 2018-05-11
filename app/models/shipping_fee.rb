class ShippingFee
  # @author hasumi
  # @since 20150819
  def self.product(line_items)
    Product.shipping_fees.find_by(point: ShippingFee.point(line_items.map(&:point).sum, line_items.map(&:quantity).sum))
  end

  # @author hasumi
  # @since 20150819
  def self.point(subtotal, total_quantity)
    if subtotal >= 5000
      0
    elsif total_quantity == 1
      450
    else
      400
    end
  end
end
