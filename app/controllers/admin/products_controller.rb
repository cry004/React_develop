class Admin::ProductsController < Admin::ResourcesController
  def index
    add_resource_action("編集", { action: "edit" })
    @items = @resources = Product.where.not(category: "shipping_fee").page(params[:page]).per(30)
  end
end
