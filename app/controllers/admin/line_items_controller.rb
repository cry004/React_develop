class Admin::LineItemsController < Admin::ResourcesController
  def show
  end

  def set_schoolbook
    line_item = LineItem.find(params[:id])
    line_item.update_attributes schoolbook_name: params[:line_item][:schoolbook_name]
    path = { controller: "admin/orders", action: :show, id: line_item.order.id }
    redirect_to path, notice: "教科書を設定しました。"
  end
end
