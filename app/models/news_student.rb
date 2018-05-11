# == Schema Information
#
# Table name: news_students
#
#  id         :integer          not null, primary key
#  news_id    :integer          not null
#  student_id :integer          not null
#  unread     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_news_students_on_news_id                 (news_id)
#  index_news_students_on_news_id_and_student_id  (news_id,student_id) UNIQUE
#  index_news_students_on_student_id              (student_id)
#
# Foreign Keys
#
#  fk_rails_27ccf49671  (student_id => students.id)
#  fk_rails_2bb59807f7  (news_id => news.id)
#

class NewsStudent < ActiveRecord::Base
  belongs_to :news,    required: true
  belongs_to :student, required: true

  validates :news_id, uniqueness: { scope: :student_id }
  validates :unread,  inclusion:  { in: [true, false] }

  scope :unreads, -> { joins(:news).merge(News.published).where(unread: true) }
end
