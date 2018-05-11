# == Schema Information
#
# Table name: posts
#
#  id                                    :integer          not null, primary key
#  question_id                           :integer
#  postable_id                           :integer
#  postable_type                         :string
#  body                                  :text
#  state                                 :string
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  executive_answerer_id                 :integer
#  comment_from_executive_answerer       :text
#  auto_reply                            :boolean          default(FALSE)
#  photo_id                              :integer
#  refuse_reason_from_gatekeeper         :string
#  refuse_reason_from_executive_answerer :string
#  pending_reason_from_gatekeeper        :string
#  fee_id                                :integer
#  fee_point                             :integer
#  accepted_at                           :datetime
#
# Indexes
#
#  index_posts_on_fee_id       (fee_id)
#  index_posts_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_429bbae7a9  (fee_id => fees.id)
#  fk_rails_551aef9ccd  (question_id => questions.id)
#


class Post < ActiveRecord::Base
  belongs_to :photo
  belongs_to :question, touch: true
  belongs_to :postable, polymorphic: true
  belongs_to :fee

  # 質問詳細ページに表示することができるポストを検索する
  scope :displayable, -> { where.not("postable_type = ? AND (state = ? OR state = ? OR state = ?)", "AdminUser", "draft", "rejected", "question_refused").order("created_at") }
  scope :history_for_answered_scope, ->(admin_user) do
    if admin_user.role == "answerer"
      where(postable: admin_user, auto_reply: false, refuse_reason_from_gatekeeper: nil).order("updated_at DESC")
    else
      where(postable_type: "AdminUser", auto_reply: false, refuse_reason_from_gatekeeper: nil).order("updated_at DESC")
    end
  end
  scope :histroy_for_answered_checked_scope, ->(admin_user) do
    if admin_user.role == "answerer"
      where(postable: admin_user, auto_reply: false, refuse_reason_from_gatekeeper: nil).order("updated_at DESC")
    else
      where(postable_type: "AdminUser", auto_reply: false, refuse_reason_from_gatekeeper: nil).order("updated_at DESC")
    end
  end

  scope :search_answers, -> do
    where(postable_type: 'AdminUser',
          auto_reply:    false,
          state:         %w(accepted_unread accepted_read))
  end

  # 承認済み回答
  scope :accepted, -> { where(postable_type: "AdminUser", state: ["accepted_read", "accepted_unread", "question_refused"], auto_reply: false) }

  scope :unreads, -> { where(postable_type: 'AdminUser', state: 'accepted_unread') }

  #get student post
  scope :student_post, -> { where(postable_type: 'Student') }

  state_machine :state, initial: :draft do
    # @author hasumi
    # @since 20150501
    # 先生の回答が承認されると、質問がanswered_checkedになる。生徒の質問が受理された時は, 生徒のポストはaccepted_readになる
    after_transition :on => :accept do |post, transition|
      unless post.from_student?
        post.question.check
        post.set_fee_point
        post.update_attributes accepted_at: Time.now
        Device.notify(post, "post_accepted")
      else
        post.read
      end
    end

    # @author hasumi
    # @since 20150519
    # 先生の回答が読まれると、未読数が1減る
    after_transition :on => :read do |post, transition|
      unless post.from_student?
        post.question.student.recount_unreads
      end
    end

    event :reject do
      transition :draft => :rejected
    end
    event :accept do
      transition [:draft, :rejected] => :accepted_unread
    end
    event :read do
      transition [:accepted_unread, :accepted_read] => :accepted_read
    end
    event :question_refuse do # 回答したが、承認者によって質問が強制リジェクトされた時
      transition :draft => :question_refused
    end
  end

  # @author hasumi
  # @since 20150501
  # 生徒からのポストか？
  # @return [Boolean]
  def from_student?
    self.postable_type == Student.to_s
  end

  # @author tamakoshi
  # @since 20150526
  # postをacceptし、上級回答者のコメントを追加する
  def accept_from_executive_answerer(comment)
    update_attributes(comment_from_executive_answerer: comment)
    accept
  end

  # @author tamakoshi
  # @since 20150526
  # 先生の回答がダメだった場合に、rejectして質問の回答者をチェックした人にする。
  def unaccept_from_executive_answerer(admin_user, reason_select, reason_text)
    update_attributes(comment_from_executive_answerer: reason_text, refuse_reason_from_executive_answerer: reason_select)
    reject
    question.return
    question.assign_and_create_post(admin_user)
  end

  # @author tamakoshi
  # @since 20150527
  # ポストが作成されてから1時間が経過したかどうかを調べる
  def spent_one_hour?
    ((Time.now - created_at) / 3600) >= 1
  end

  # @author tamakoshi
  # @since 20150530
  # 管理画面上でのステートの表示
  def state_for_admin
    case question.try(:state)
    when "assigned"
      "下書き"
    when "answered_unchecked"
      "チェック待ち"
    when "answered_checked", "closed"
      accepted_read? ? "チェック済み + 生徒既読" : "チェック済み + 生徒未読"
    when "working"
      "校閲作業中"
    else
      "棄却"
    end
  end

  # @author tamakoshi
  # @since 20151020
  # accepted時にfee_pointを設定する。
  def set_fee_point
    postable_user = self.postable
    if postable_user.class.to_s == "AdminUser" && !self.auto_reply
      postable_user.set_rank(Time.now.strftime("%Y%m").to_i)
      postable_user.reload
      self.update_attributes! fee_point: Settings.fee_point_base.send(postable_user.rank)
    end
  end

  def poster_type
    return 'student' if self.postable_type == 'Student'
    return 'teacher' unless self.auto_reply
    'auto_reply'
  end
end
