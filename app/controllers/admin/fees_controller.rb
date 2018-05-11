class Admin::FeesController < Admin::ResourcesController
  def index
    add_resource_action("", { action: "" })
    @items = @resources = @admin_user.fees.order("created_at DESC").page(params[:page]).per(15)
  end

  def show
    redirect_to controller: "admin/fees", action: "index"
  end
end
