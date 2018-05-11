module API::V5::NotificationsHelpers
  LIMITED_NUMBER = 20

  def search_notifications(student:)
    notifications = search_news(student: student) +
                    search_teacher_recommendations(student: student)
    notifications = notifications.sort_by do |notification|
      notification.try(:published_at) || notification.try(:created_at)
    end.reverse
    notifications.first(LIMITED_NUMBER)
  end

  private

  def search_teacher_recommendations(student:)
    student.teacher_recommendations
           .notifiable
           .includes(:teacher)
           .order(created_at: :desc)
           .limit(LIMITED_NUMBER)
  end

  def search_news(student:)
    student.news.published.recent.select_for_list.limit(LIMITED_NUMBER)
  end
end
