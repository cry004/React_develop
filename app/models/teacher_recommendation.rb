# == Schema Information
#
# Table name: teacher_recommendations
#
#  id           :integer          not null, primary key
#  teacher_id   :integer
#  student_id   :integer
#  state        :string
#  message      :text
#  total_videos :integer          default(0), not null
#  unread       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  school       :string           not null
#  kys_schdl_no :integer
#
# Indexes
#
#  index_teacher_recommendations_on_kys_schdl_no  (kys_schdl_no)
#  index_teacher_recommendations_on_student_id    (student_id)
#  index_teacher_recommendations_on_teacher_id    (teacher_id)
#

class TeacherRecommendation < ActiveRecord::Base
  include ::ApiPageable
  api_per_page_num 20

  belongs_to :teacher
  belongs_to :student
  has_many :teacher_recommendation_videos, dependent: :destroy
  has_many :videos,
           through: :teacher_recommendation_videos, dependent: :destroy

  # @author tamakoshi
  # @since 20160208
  # 各teacherごとに通知可能状態のレコメンドを取得する。
  scope :notifiable, ->() { where(state: 'notifiable') }
  scope :unreads, -> { where(unread: true) }
  # @author tamakoshi
  # @since 20160208
  scope :included_requirement, ->() do
    includes(
      :teacher,
      videos: [
        {
          stars: :student,
          completes: :student
        },
        :subject,
        :video_title_image,
        :video_subtitle_image
      ]
    )
  end

  # @author tamakoshi
  # @since 20160209
  scope :older_records, ->(id) do
    where('id < ?', id).order('id DESC, created_at DESC')
  end

  # @author tamakoshi
  # @since 20160209
  # ある生徒に紐づくある先生の最新のオススメが作成されたときに
  # その前の最新のオススメは通知一覧に出現しないようにする。
  before_create :update_all_except_self_not_notifiable

  state_machine :state, initial: :notifiable do
    # @author tamakoshi
    # @since 20160209
    event :hide do
      transition :notifiable => :not_notifiable
    end
    # @author tamakoshi
    # @since 20160209
    # 生徒が先生管理の画面から先生のオススメ動画を見られないようにした場合に
    # 論理削除する
    event :logical_delete do
      transition %i(notifiable not_notifiable) => :deleted
    end
  end

  # @author tamakoshi
  # @since 20160209
  def title_at_notification
    "#{teacher.honorific_name}から映像授業が届いています"
  end

  private

  # @author tamakoshi
  # @since 20160209
  def update_all_except_self_not_notifiable
    TeacherRecommendation.where(teacher: teacher, student: student, school: school)
                         .where.not(id: id)
                         .update_all(state: 'not_notifiable')
  end
end
