object @current_student

attributes(
  :id,
  :sit_cd,
  :school,
  :available_point,
  :current_monthly_point,
  :avatar,
  :nick_name,
  :full_name
)

node(:school_year)                { @current_student.schoolyear }
node(:school_address)             { @current_student.school_prefecture }
node(:question_point)             { Product.question_points}
node(:purchasable)                { @current_student.purchasable? }
node(:unread_notifications_count) { @current_student.unread_notification_num }
node(:unread_news_count)          { @current_student.unread_news_num }
node(:first_login)                { @current_student.dialog_enabled }
node(:is_internal_member)         { @current_student.fist? }
node(:is_new_user)                { @current_student.new_user? }
