# == Schema Information
#
# Table name: questions
#
#  id                     :integer          not null, primary key
#  student_id             :integer
#  video_id               :integer
#  state                  :string
#  priority               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  answerer_id            :integer
#  subject_id             :integer
#  order_id               :integer
#  gatekeeper_id          :integer
#  position               :integer
#  opened_at              :datetime
#  accepted_or_refused_at :datetime
#  favorite               :boolean          default(FALSE)
#  school                 :string
#
# Indexes
#
#  index_questions_on_student_id  (student_id)
#  index_questions_on_subject_id  (subject_id)
#  index_questions_on_video_id    (video_id)
#
# Foreign Keys
#
#  fk_rails_6dfff3afe3  (video_id => videos.id)
#  fk_rails_d78ac03c88  (student_id => students.id)
#


class Question < ActiveRecord::Base
  paginates_per 30
  extend ApplicationHelper
  belongs_to :order
  belongs_to :student
  belongs_to :video
  belongs_to :subject
  belongs_to :answerer, :class_name => "AdminUser"
  has_one :incomprehensible, dependent: :destroy
  has_many :posts, dependent: :destroy

  STATE_MAP = {
    'unopen'   => %w(initial draft),
    'open'     => %w(open accepted assigned answered_unchecked examining checking pending),
    'refused'  => %w(refused),
    'answered' => %w(answered_checked),
    'resolved' => %w(closed)
  }

  before_create do
    self.school = self.student.school
  end

  default_scope -> { where.not(state: ["initial", "draft"]) }

  scope :search_and_order, -> (params) do
    with_state(params[:state])
      .with_subject_id(params[:subject_id])
      .with_favorite(params[:favorite])
      .with_from_date(params[:from_date])
      .with_to_date(params[:to_date])
      .with_type(params[:type])
      .order(params[:order_by])
  end

  scope :with_state,      -> (state)      { where(state: state) if state.present? }
  scope :with_subject_id, -> (subject_id) { where(subject_id: subject_id) if subject_id.present? }
  scope :with_favorite,   -> (favorite)   { where(favorite: favorite) if favorite.present? }
  scope :with_from_date,  -> (date)       { where('? <= created_at', date) if date.present? }
  scope :with_to_date,    -> (date)       { where('created_at <= ?', date) if date.present? }
  scope :with_type,       -> (type)       { where(type) if type.present? }

  scope :auto_assign_scope,  -> { where("opened_at < (?) AND state IN (?)", Time.now.beginning_of_day, ["open", "examining", "accepted", "assigned", "checking", "answered_unchecked"]).order("opened_at") }
  scope :cleanup_scope,      -> { includes(:posts).where("opened_at <= (?) AND state = ?", 1.weeks.ago, "refused")}
  scope :answered_unchecked_scope, ->(admin_user) { where(state: ["answered_unchecked", "checking"]).order("opened_at DESC") }
  scope :answered_checked_scope,   ->(question_ids) { where(state: "answered_checked", id: question_ids).order("opened_at DESC") }
  # 回答履歴
  scope :answered_all_scope, ->(admin_user) do
    if admin_user.role == "answerer"
      questin_ids = admin_user.posts.includes(:question).select{|p| (["answered_unchecked", "answered_checked", "closed", "deleted"].include? p.question.state) || p.state == "rejected" }.map{ |p|p.question.id }
      where(id: questin_ids)
    else
      where.not(answerer_id: nil, state: ["open", "examing", "refused", "assigned"])
    end
  end
  # 検閲履歴
  scope :examined_scope, ->(admin_user) do
    if admin_user.role == "gatekeeper"
      where(gatekeeper_id: admin_user.id).where.not(state: ["open", "examining"]).order("accepted_or_refused_at DESC")
    else
      where.not(gatekeeper_id: nil, state: ["open", "examining"]).order("accepted_or_refused_at DESC")
    end
  end
  # 未検閲
  scope :open_scope, ->(admin_user) do
    case admin_user.role
    when "admin", "executive_answerer"
      where(state: ["open", "examining"]).order("opened_at DESC")
    else
      where(state: "open").order("opened_at DESC")
    end
  end
  # ポイント返金処理する質問のscope
  scope :return_point_scope, -> do
    includes(:order).where.not(state: ["answered_checked", "closed", "refused"]).where("opened_at < (?)", Time.now.yesterday.beginning_of_day).where("orders.state" => "ordered").references(:order)
  end
  scope :answered_scope, ->(admin_user) do
    questin_ids = admin_user.posts.includes(:question).select{|p| (["answered_unchecked", "answered_checked", "closed", "deleted"].include? p.question.state) || p.state == "rejected" }.map{ |p|p.question.id }
    where(id: questin_ids)
  end
  scope :accepted_scope, ->(admin_user) do
    digit_num = Settings.digits_number_of_question_search
    case admin_user.role
    when "answerer"
      # 回答者の場合、回答中の質問は除いたものを表示する。digit_numによって質問のidの末尾何桁かと一致する質問を表示するようにできる。
      if ( digit_num == 0)
        where("state = ?", "accepted").order("opened_at DESC")
      else
        id = admin_user.id.to_s[-digit_num..-1]
        where("cast(id as text) like (?) AND state = ?", "%#{id}", "accepted").order("opened_at DESC")
      end
    when "executive_answerer", "admin"
      # 上級回答者,管理者の場合すべての未回答の質問を(回答中も含めて)表示する
      where(state: ["accepted", "assigned"]).order("opened_at DESC")
    end
  end

  # 作成日が前日でかつ回答できていない質問一覧
  scope :question_notification_scope, -> do
    where.not(state: ["answered_checked", "closed", "refused", "deleted"]).where("opened_at >= (?) AND opened_at < (?)", Time.now.yesterday.beginning_of_day, Time.now.beginning_of_day)
  end

  # 保留にした質問一覧
  scope :pending_scope, -> { where(state: :pending)}

  scope :displayables, -> { unscope(where: :state).where.not(state: %i(initial deleted)) }

  # deleted state以外を表示する
  scope :except_deleted_state_scope, -> { unscope(where: :state).where.not(state: "deleted") }

  # 解決済みの質問
  scope :resolved, -> { where(state: "closed") }
  # 解決済み以外の質問
  scope :no_resolved, -> { unscope(where: :state).where.not(state: ["closed", "deleted"]) }
  # 未質問
  scope :unopen, -> { where(state: ["initial", "draft"]) }
  # 質問中
  scope :opened, -> { where(state: ["open", "accepted", "assigned", "answered_unchecked", "examining", "checking", "pending"]) }
  # 回答あり
  scope :answered, -> { where(state: "answered_checked") }
  # やり直し
  scope :refused, -> { where(state: "refused") }

  scope :drafts, -> { unscope(where: :state).where(state: 'draft') }

  state_machine :state, initial: :initial do
    # @author tamakoshi
    # @since 20150521
    # gatekeeperが質問を受け入れると、生徒のポストがacceptされる
    after_transition :on => :accept do |question, transition|
      question.update_attributes accepted_or_refused_at: Time.now
      question.posts.where(postable_type: Student.to_s).last.accept
    end

    # @author tamakoshi
    # @since 20150521
    # gatekeeperが質問を拒否すると、生徒のポストがrejectされ、ポイントが返却される。
    after_transition :on => :refuse do |question, transition|
      question.update_attributes accepted_or_refused_at: Time.now
      question.posts.where(postable_type: Student.to_s).last.reject
      question.order.cancel
      question.student.recount_unreads
      Device.notify(question.posts.where(postable_type: AdminUser.to_s, auto_reply: false).last)
    end

    # @author tamakoshi
    # @since 20150526
    # 回答者が質問のアサインを外すとanswerer_idがnilになり、関連するAdminUserのポストが削除される
    after_transition :on => :deassign do |question, transition|
      question.update_attributes(answerer_id: nil)
      question.posts.where(postable_type: AdminUser.to_s, auto_reply: false).last.delete
    end

    # @author tamakoshi
    # @since 20150526
    # 回答者チェック者が先生の回答のチェックしてダメだった場合, answerer_idをnilにする
    after_transition :on => :return do |question, transition|
      question.update_attributes(answerer_id: nil)
    end

    # @author tamakoshi
    # @since 20150610
    # 承認者が回答承認作業を中断した場合、executive_answerer_idをnilにする。
    after_transition :on => :stop_work do |question, transition|
      post = question.posts.where(postable_type: "AdminUser", auto_reply: false, state: "draft").last
      post.update_attributes(executive_answerer_id: nil)
    end
    # @author tamakoshi
    # @since 20150610
    # 検閲者が検閲作業を中断した場合、gatekeeper_idをnilにする。
    after_transition :on => :stop_examine do |question, transition|
      question.update_attributes(gatekeeper_id: nil)
    end

    # @author tamakoshi
    # @since 20150615
    # 承認者が回答を承認したら、生徒の未読数を増やす。Questionに紐づくOrderを確定させる。
    after_transition :on => :check do |question, transition|
      question.student.recount_unreads
      question.order.settle
    end

    # @author tamakoshi
    # @since 20150716
    # openになった時に,opened_atを更新する
    after_transition :on => :be_open do |question, transition|
      question.update_attributes opened_at: Time.now
    end

    # @author tamakoshi
    # @since 20150716
    # 保留にしたときにgatekeeper_idがnilになるようにする。
    after_transition :on => :be_pending do |question, transition|
      question.update_attributes gatekeeper_id: nil
    end

    # @author tamakoshi
    # @since 20150702
    # 承認者が質問を強制差し戻し、かつその質問に先生の回答が紐付いていた場合、その回答のステートは、question_refusedになる
    # 先生の回答に対する質問が強制的にやり直しになった場合ポイントを付与する
    after_transition :on => :force_reject do |question, transition|
      if (transition.from_name == :answered_unchecked || transition.from_name == :checking)
        admin_user_post = question.posts.where(postable_type: "AdminUser", state: "draft", auto_reply: false).last
        admin_user_post.set_fee_point
        admin_user_post.update_attributes accepted_at: Time.now, state: "question_refused"
      end
      question.posts.where(postable_type: Student.to_s).last.reject
      question.order.cancel
      question.student.recount_unreads
      Device.notify(question.posts.where(postable_type: AdminUser.to_s, auto_reply: false).last)
    end

    event :be_open do
      transition [:initial, :draft] => :open
    end
    event :be_draft do
      transition :initial => :draft
    end
    event :be_pending do
      transition :examining => :pending
    end
    event :examine do # gatekeeperが検閲中にした。
      transition [:open, :pending] => :examining
    end
    event :stop_examine do # gatekeeperが検閲をやめた。
      transition :examining => :open
    end
    event :refuse do # gatekeeperが質問回答を拒否
      transition :examining => :refused
    end
    event :accept do # gatekeeperが質問を受け入れた。アサイン待ち
      transition :examining => :accepted
    end
    event :assign do # answererまたはexecuive_answererにアサインされた
      transition :accepted => :assigned
    end
    event :deassign do # answererまたはexecuive_answererがアサインを外す
      transition :assigned => :accepted
    end
    event :answer do # 回答したがまだ承認されていない。
      transition :assigned => :answered_unchecked
    end
    event :work do # 回答したがまだ承認作業中
      transition :answered_unchecked => :checking
    end
    event :stop_work do # 承認者が承認作業をやめた
      transition :checking => :answered_unchecked
    end
    event :check do # 回答がexecuive_answererに承認された
      transition :checking => :answered_checked
    end
    event :return do
      transition [:answered_unchecked, :checking] => :assigned
    end
    event :close do # 生徒が「解決した」を押した
      transition :answered_checked => :closed
    end
    event :eliminate do # 生徒がやり直し or 解決済みの質問を削除した。
      transition [:refused, :closed] => :deleted
    end

    event :force_reject do # 承認者・回答者が強制的に質問を削除した
      transition [:accepted, :assigned, :answered_unchecked, :checking] => :refused
    end

    event :unresolve do # 解決済みの質問を回答ありの状態に戻した。
      transition :closed => :answered_checked
    end
  end

  # @author tamakoshi
  # @since 20150520
  # 動画に紐付いた質問を作成する。QuestionとPostを作成する。
  def self.create_with_video(params, student)
    ActiveRecord::Base.transaction do
      order = consume_point(student)
      video = Video.find(params[:video_id])
      video.incomprehensible_thumbnail_url(params[:position])
      photo = video.thumbnails.find_by(position: round_off(params[:position]))
      incomprehensible = Incomprehensible.find_by(video_id: params[:video_id], position: params[:position], student: student)
      question = self.create(student: student, video: video, subject: video.subject, order: order, state: "open")
      incomprehensible.update_attributes(question_id: question.id) if incomprehensible
      Post.create(question: question, postable: student, body: params[:body], photo: photo, state: "accepted_read")
      question.create_posts_from_bot
    end
  end

  # @author tamakoshi
  # @since 20150520
  # 動画に紐付かない質問を作成する。QuestionとPostとQuestionPhotoを作成する。
  def self.create_without_video(params, student)
    ActiveRecord::Base.transaction do
      order = consume_point(student)
      photo = create_question_photo(params[:upload_file])
      subject = Subject.find_by(name: params[:subject], type: "regular")
      question = self.create(student: student, subject: subject, order: order, state: "open")
      Post.create(question: question, postable: student, body: params[:body], photo: photo, state: "accepted_read")
      question.create_posts_from_bot
    end
  end

  # @author tamakoshi
  # @since 20150525
  # 質問した時にポイントが消費されるようにする
  def self.consume_point(student)
    product = Product.find_by(category: "question")
    Order.execute(student, [product])
  end

  # @author tamakoshi
  # @since 20150526
  # 回答者が自分にアサインするを押した時にアサインし、Postを作成する
  def assign_and_create_post(admin_user)
    self.update_attributes(answerer_id: admin_user.id)
    self.assign
    Post.create!(question: self, postable: admin_user)
  end

  # @author tamakoshi
  # @since 20150526
  # 回答者が自分にアサインしてから1時間立っていた場合にアサインを外す。
  def deassign_if_one_hour_spent(admin_user)
    post = posts.find_by(postable: admin_user)
    if post.try(:spent_one_hour?) && can_deassign?
      self.deassign
    else
      false
    end
  end

  # @author tamakoshi
  # @since 20150526
  # アップロードされた写真からQuestionPhotoを作成する
  def self.create_question_photo(upload_file)
    if upload_file
      file = upload_file.is_a?(ActionDispatch::Http::UploadedFile) ? upload_file : ActionDispatch::Http::UploadedFile.new(upload_file)
      original_filename = file.original_filename
      extension = original_filename.split(".")[-1]
      file.original_filename = "temp#{Time.now.to_i}#{SecureRandom.uuid}.#{extension}"
      QuestionPhoto.create(image: file)
    else
      return nil
    end
  end

  # @author tamakoshi
  # @since 20150702
  def notification_of_later_reason
    post = Post.new(question: self, postable_type: "AdminUser", auto_reply: true, body: Settings.message_of_notification_of_later_reason_post, state: "accepted_unread")
    post.save
    self.student.recount_unreads
  end

  # @author tamakoshi
  # @since 20150610
  # 昨日以前(昨日は含まない)に作られた質問に回答できていない場合、ポイントを返却する。
  def exec_return_points
    if self.order.state == "ordered"
      self.order.cancel
      self.create_apologized_post
    end
  end

  # @author tamakoshi
  # @since 20150629
  # ポイント返却処理時に謝罪ポストをする。
  def create_apologized_post
    post = Post.new(question: self, postable_type: "AdminUser", auto_reply: true, body: Settings.message_of_apologized_post, state: "accepted_unread")
    post.save
    self.student.recount_unreads
  end

  # @author tamakoshi
  # @since 20150530
  # ボットからの投稿
  def create_posts_from_bot
    Post.create( question: self,
                 state: "accepted_unread",
                 postable_type: "AdminUser",
                 auto_reply: true,
                 body: PostMessage.instance.default_reply_message
                )
  end

  # @author tamakoshi
  # @since 20150729
  def delete_tryit
    if delete_state?
      admin_user_accepted_post = posts.accepted.last
      # 関連するpostに承認済みの回答が紐付いていた場合は、deleteせずstateをdeletedにする。
      if admin_user_accepted_post.present?
        self.eliminate
      else
        posts.delete_all
        self.destroy
      end
    end
  end

  # @author tamakoshi
  # @since 20150729
  def delete_state?
    ["initial", "draft", "refused"].include? self.state
  end

  # @author tamakoshi
  # @since 20150710
  def self.create_tryit(video, student, thumbnail_url, position)
    photo = Thumbnail.find_by(resource_url: thumbnail_url)
    question = self.create(student: student, video: video, subject: video.try(:subject).try(:convert_for_question_subject), position: position)
    Post.create(question: question, postable: student, photo: photo, state: "draft")
    question.id
  end

  # @author tamakoshi
  # @since 20150710
  def update_with_video(body, create_flag)
    if create_flag
      ActiveRecord::Base.transaction do
        order = Question.consume_point(student)
        self.posts.where(postable_type: "Student").first.update_attributes(body: body, state: "accepted_read")
        self.update_attributes order: order
        self.be_open
        self.create_posts_from_bot
      end
    else
      self.posts.where(postable_type: "Student").first.update_attributes(body: body, state: "draft")
      self.be_draft
    end
    self
  end

  def update_without_video(upload_file, subject_name, body, create_flag, old_question_flag = true)
    student_post = self.posts.where(postable_type: :Student).first
    school       = student.school if old_question_flag # FIXME: remove this condition when v3 and v4 aboid
    subject      = Subject.for_question_subject(school: school, name: subject_name)
    if create_flag
      ActiveRecord::Base.transaction do
        order = Question.consume_point(student)
        photo = upload_file ? Question.create_question_photo(upload_file) : student_post.photo
        self.update(subject: subject, order: order)
        self.be_open
        student_post.update(photo: photo, body: body, state: :accepted_read)
        self.create_posts_from_bot
      end
    else
      photo = upload_file ? Question.create_question_photo(upload_file) : student_post.photo
      self.update(subject: subject) if subject_name
      student_post.update(photo: photo, body: body, state: :draft)
      self.be_draft
    end
    self
  end

  def refuse_and_post_refuse_reason(refuse_reason_select, refuse_reason_text, admin_user)
    create_refuse_post(refuse_reason_select, refuse_reason_text, admin_user)
    self.refuse
  end

  # @author tamakoshi
  # @since 20150703
  # 管理者・承認者が検閲後に差し戻す
  def force_reject_and_create_post(refuse_reason_select, refuse_reason_text, admin_user)
    create_refuse_post(refuse_reason_select, refuse_reason_text, admin_user)
    self.force_reject
  end

  def create_refuse_post(refuse_reason_select, refuse_reason_text, admin_user)
    if refuse_reason_select == "その他（→答えられないのでもう一度質問してください）"
      body = "答えられないのでもう一度質問してください。\n※この質問のポイントは返還されました。"
    else
      body = "#{refuse_reason_select}\n※この質問のポイントは返還されました。"
    end
    Post.create(question: self, state: "accepted_unread", postable: admin_user, body: body, refuse_reason_from_gatekeeper: "#{refuse_reason_select}#{refuse_reason_text}")
  end

  def pending_and_add_pending_reason(pending_reason_text)
    student_post = posts.where(postable_type: "Student").first
    student_post.update_attributes pending_reason_from_gatekeeper: pending_reason_text
    be_pending
  end

  def self.convert_to_server_state(states)
    states.map { |state| STATE_MAP[state] }.flatten
  end

  # @author tamakoshi
  # @since 20150730
  # お気に入りに登録
  def add_favorite
    self.update_attributes favorite: true
  end

  # @author tamakoshi
  # @since 20150730
  # お気に入りにから外す
  def remove_favorite
    self.update_attributes favorite: false
  end

  # @author tamakoshi
  # @since 20150928
  # typeノードを生成する
  def build_type_node
    self.video_id ? "video" : "other"
  end

  # typus向けアクセサメソッド

  def student_sit_cd
    student.try(:sit_cd) || student.username
  end

  def student_schoolyear
    student.schoolyear
  end

  def has_video?
    video ? "◯" : ""
  end

  def subject_name
    Subject::V3::SUBJECT_NAME[school][subject&.name]
  end

  def video_subject_name
    return unless subject = video.try!(:subject)

    school = subject.school
    key    = school == 'c' ? subject.type : subject.name_and_type

    Subject::V3::SUBJECT_TYPE[school][key]
  end

  def state_name_for_app
    case state
    when 'initial'
      'initial'
    when 'draft'
      'draft'
    when 'open', 'accepted', 'assigned', 'answered_unchecked', 'examining', 'checking', 'pending'
      'open'
    when 'refused'
      'refused'
    when 'answered_checked'
      'answered'
    when 'closed'
      'resolved'
    else
      'open'
    end
  end

  def unread_posts?
    posts.unreads.exists?
  end

  def first_post_body
    posts.student_post.first&.body
  end

  def answerer_email
    AdminUser.find_by(id: answerer_id).try(:email)
  end

  def gatekeeper_email
    AdminUser.find_by(id: gatekeeper_id).try(:email)
  end

  def video_filename
    video.filename
  end

  def student_sit_cd
    student.sit_cd
  end

  def student_username
    student.username
  end

  def student_name
    student.full_name
  end

  # typusでpositionカラムを呼び出すとおかしな表示になるため。
  def decorate_position
    position
  end

  def notebook_url
    video.notebook_url
  end

  def school_type_name
    Settings.school_type_name[school]
  end

  def type
    self.video_id ? 'video' : 'other'
  end

  def title
    posts.student_post.first&.body&.truncate(15)
  end
end
