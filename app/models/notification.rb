# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  notifiable_id     :integer
#  notifiable_type   :string
#  fist_id           :integer
#  unread            :boolean          default(TRUE)
#  notification_type :string
#  notified_at       :datetime
#  title             :string
#  content           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_notifications_on_notifiable_id_and_notifiable_type  (notifiable_id,notifiable_type)
#


class Notification < ActiveRecord::Base
  belongs_to :notifiable, polymorphic: true
end
