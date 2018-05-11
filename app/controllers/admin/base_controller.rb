# typusから拝借
# https://github.com/typus/typus/blob/master/app/controllers/admin/base_controller.rb
class Admin::BaseController < ActionController::Base
  protect_from_forgery with: :exception
  def json_logger(event_name, event_data: {}, user: nil, logger_level: :info, req: request)
    user = @admin_user
    locals = { request:    req,
               user:       user,
               event_name: event_name,
               event_data: event_data }
    message = render_to_string '/log/event_log.json', locals: locals, layout: false

    Rails.logger.send(logger_level, message)
  end

  #include Admin::Hooks
  include Typus::Authentication::const_get(Typus.authentication.to_s.classify)

  before_filter :verify_remote_ip, :reload_config_and_roles, :authenticate, :set_locale, :judge_rank

  helper_method :admin_user, :current_role

  protected

  def verify_remote_ip
    if !request.local? && Typus.ip_whitelist.any?
      unless Typus.ip_whitelist.include?(request.ip)
        render text: 'IP not in our whitelist.'
      end
    end
  end

  def reload_config_and_roles
    Typus.reload! if Rails.env.development?
  end

  def set_locale
    I18n.locale = admin_user.respond_to?(:locale) ? admin_user.locale : Typus::I18n.default_locale
  end

  def zero_users
    Typus.user_class.count.zero?
  end

  # @author tamakoshi
  # @since 20150807
  # Not allowed!ではなく404にする。
  def not_allowed(reason = 'Not allowed!')
    render file: "/public/404.html", layout: nil
  end

  def admin_user_params
    params[Typus.user_class_as_symbol]
  end

  # @author tamakoshi
  # @since 20150807
  def judge_rank
    admin_user.try(:exec_decide_answerer_rank)
  end
end
