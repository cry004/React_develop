class Admin::DashboardController < Admin::BaseController
  def index
    case @admin_user.role
    when "admin"
    when "contents_manager"
      redirect_to ({ controller: "admin/videos", action: :index })
    when "shipping_manager", "telephone_communicator"
      redirect_to ({ controller: "admin/orders", action: :index })
    else
      redirect_to ({ controller: "admin/questions", action: :index })
    end
  end
end
