class ErrorsController < ActionController::Base
  include API::Root.helpers
  protect_from_forgery with: :exception

  def render_404
    logger("RoutingError", event_data: { error_type: "RoutingError", error_message: env["action_dispatch.exception"].message }, logger_level: "error")
    render file: "/public/404.html"
  end
end
