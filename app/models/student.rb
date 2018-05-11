# == Schema Information
#
# Table name: students
#
#  id                                 :integer          not null, primary key
#  sit_cd                             :string
#  json                               :json
#  school                             :string           default("c"), not null
#  schoolbooks                        :json
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  dialog_enabled                     :boolean          default(TRUE)
#  parent_id                          :integer
#  username                           :string           default(""), not null
#  encrypted_password                 :string           default(""), not null
#  sign_in_count                      :integer          default(0), not null
#  current_sign_in_at                 :datetime
#  last_sign_in_at                    :datetime
#  current_sign_in_ip                 :inet
#  last_sign_in_ip                    :inet
#  gknn_cd                            :string
#  school_name                        :string
#  family_name                        :string
#  first_name                         :string
#  family_name_kana                   :string
#  first_name_kana                    :string
#  sex                                :string
#  state                              :string
#  birthday                           :date
#  unreads                            :integer          default(0)
#  original_member_type               :string
#  current_member_type                :string
#  current_month                      :integer
#  it_login_kh_flag                   :string           default("1")
#  ins_dt                             :datetime
#  spent_point                        :integer          default(0)
#  current_monthly_point              :integer          default(0)
#  following_monthly_point            :integer          default(0)
#  school_prefecture_code             :integer
#  condition                          :json
#  access_token                       :string
#  my_box_first_seen                  :boolean          default(TRUE)
#  teacher_recommendations_first_seen :boolean          default(TRUE)
#  avatar                             :integer
#  nick_name                          :string
#  private_flag                       :boolean          default(TRUE), not null
#  experience_point                   :integer          default(0), not null
#  level                              :integer          default(1), not null
#  viewing_time                       :integer          default(0), not null
#  trophies_count                     :integer          default(0), not null
#  classroom_id                       :integer
#
# Indexes
#
#  index_students_on_classroom_id  (classroom_id)
#  index_students_on_parent_id     (parent_id)
#  index_students_on_sit_cd        (sit_cd) UNIQUE
#  index_students_on_username      (username) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0a4ac52d98  (level => levels.level)
#  fk_rails_4fde1dad9c  (classroom_id => classrooms.id)
#  fk_rails_d3631a714a  (parent_id => parents.id)
#

class Student < ActiveRecord::Base
  include Billing

  # define default scope
  default_scope -> { order(:id) }

  # define constants
  SEX_CODE = {
    '01' => 'male',
    '02' => 'female'
  }.freeze

  STATUS_CODE = {
    '01' => 'pending',
    '02' => 'active',
    '03' => 'inactive',
    '04' => 'inactive'
  }.freeze

  # define scopes
  scope :except_try_employee, -> {
    # 社員コードを除いた生徒を抽出する
    where.not("sit_cd LIKE 'S%' OR sit_cd LIKE '50089%'")
  }
  scope :group_by_pref_code, -> { unscoped.group(:school_prefecture_code) } # unscope default_scope
  scope :active_users,       -> { where(state: :active) }
  scope :news_deliverable,   -> { where(state: :active) }
  scope :rankable,           -> { unscoped.where(private_flag: true) }      # unscope default_scope
  scope :group_by_class_id,  -> { unscoped.group(:classroom_id) }
  scope :group_by_class_pref_code, -> { unscoped.joins(:classroom).merge(Classroom.group_by_pref_code) }
  scope :classroom_rankable, -> { unscoped.joins(:classroom).merge(Classroom::Klassroom.status_available) }
  scope :schoolhouse_rankable, -> { unscoped.joins(:classroom).merge(Classroom::Schoolhouse.status_available) }
  scope :schollbooks_settings_state_true, -> {
    where("schoolbooks -> 'settings_state' -> 'c1' ->> 'english' = (?)", 'true')
  }
  scope :of_city, ->(city_codes)    { where(school_prefecture_code: city_codes) if city_codes.present? }
  scope :of_member_types, ->(types) { where(current_member_type: types) if types.present? }
  scope :of_gknn_cds, ->(gknn_cds)  { where(gknn_cd: gknn_cds) if gknn_cds.present? }

  # define macros related to attr_*
  attr_accessor :update_mode, :create_mode

  # assosiations
  belongs_to :parent
  belongs_to :classroom
  has_many :completables,            dependent: :destroy
  has_many :completes,               dependent: :destroy
  has_many :video_viewings,          dependent: :destroy
  has_many :credits,                 dependent: :destroy
  has_many :curriculums,             dependent: :destroy
  has_many :devices,                 dependent: :destroy, as: :pushable
  has_many :incomprehensibles,       dependent: :destroy
  has_many :learning_reports,        dependent: :destroy
  has_many :learnings,               dependent: :destroy
  has_many :news_students,           dependent: :destroy
  has_many :news,                    through: :news_students
  has_many :notifications,           dependent: :destroy, as: :notifiable
  has_many :orders,                  dependent: :destroy, as: :orderable
  has_many :posts,                   dependent: :destroy, as: :postable
  has_many :questions,               dependent: :destroy
  has_many :ranks,                   dependent: :destroy, as: :ranker
  has_many :spent_point_histories,   dependent: :destroy
  has_many :stars,                   dependent: :destroy
  has_many :teacher_recommendations, dependent: :destroy
  has_many :videos,                  through: :video_viewings
  has_many :watched_videos,          through: :watched_video_viewings, source: :video
  has_many :watched_video_viewings,  -> {where(video_viewings: { watched: true})}, class_name: VideoViewing.name, foreign_key: :student_id

  # define validations
  validate :username_cannot_be_fist_sitcd_at_parent,
           if: -> { Rails.env.www_production? }
  validate :valid_condition
  validate :only_fist_member_has_classroom_id

  validates :sex, inclusion: { in: %w(male female) },
                  allow_nil: true, on: :update
  validates :original_member_type, inclusion: { in: %w(tryit fist fc tester) }
  validates :current_member_type, inclusion: { in: %w(tryit fist fc tester) }
  validates :username, length: { minimum: 6 }
  validates :username,
            uniqueness: { message: 'がすでに存在するため、このIDは'\
                                   'ご利用いただけません。別のIDをご利用ください。' }
  validates :username,
            format: { with: /\A[0-9a-zA-Z!#$%^&*()_\-+=.<>]+\z/,
                      message: 'に使える文字種類は半角英数字および'\
                               ' ! # $ % ^ & * ( ) _ - + = . < > だけです。' },
            if: -> { create_mode == :additional }
  validates :username,
            format: { with: /\A[0-9a-zA-Z!@#$%^&*()_\-+=.<>]+\z/,
                      message: 'に使える文字種類は半角英数字および'\
                               ' ! @ # $ % ^ & * ( ) _ - + = . < > だけです。' },
            unless: -> { create_mode == :additional }
  validates :first_name, presence: true, on: :update
  validates :family_name_kana, presence: true, on: :update
  validates :first_name_kana, presence: true, on: :update
  validates :first_name_kana, format: { with: /\A[.ァ-ヾ]+\z/ }, on: :update
  validates :first_name_kana, format: { with: /\A[.ァ-ヾ]+\z/ }, on: :create,
            if: -> { Rails.env.include?('teacher') }
  validates :family_name, presence: true, on: :update
  validates :family_name_kana, format: { with: /\A[.ァ-ヾ]+\z/ }, on: :update
  validates :family_name_kana, format: { with: /\A[.ァ-ヾ]+\z/ }, on: :create,
            if: -> { Rails.env.include?('teacher') }
  validates :password, presence: true, length: { minimum: 8, maximum: 255 },
            on: :create, if: -> { !Rails.env.include?('teacher') }
  validates :password, presence: true, length: { minimum: 4, maximum: 255 },
            on: :create, if: -> { Rails.env.include?('teacher') }
  validates :password, length: { minimum: 4, maximum: 255 }, on: :update,
            allow_blank: true, if: -> { Rails.env.include?('teacher') }

  validates :password, length: { minimum: 8, maximum: 255 }, on: :update,
            if: -> { update_mode == :without_current_password &&
                     !Rails.env.include?('teacher') }
  validates_confirmation_of :password
  # validates :sex, presence: true　このコメントアウトはstudent側だけ
  # validates :birthday, presence: true, on: :update
  validates :gknn_cd, presence: { message: 'を選択してください。' }, on: :update
  validates :current_monthly_point,
            inclusion: Settings.options_for_upper_point_limit
  validates :following_monthly_point,
            inclusion: Settings.options_for_upper_point_limit

  validates :sex, inclusion: { in: %w(male female) },
            allow_nil: true, if: -> { create_mode == :additional }
  validates :first_name, presence: true, if: -> { create_mode == :additional }
  validates :family_name_kana, presence: true,
            if: -> { create_mode == :additional }
  validates :first_name_kana, presence: true,
            if: -> { create_mode == :additional }
  validates :family_name, presence: true, if: -> { create_mode == :additional }
  validates :sex, presence: true, if: -> { create_mode == :additional }
  validates :birthday, presence: true, if: -> { create_mode == :additional }
  validates :gknn_cd, presence: { message: 'を選択してください。' },
            if: -> { create_mode == :additional }
  validates :school_name, presence: true,
            if: -> { create_mode == :additional },
            unless: -> { gknn_cd == '60' }

  validates :school_name, on: :update, presence: true,
            unless: -> { gknn_cd == '60' }
  validate :username_cannot_be_fist_sitcd_at_parent,
           if: -> { Rails.env.www_production? || (create_mode == :additional) }

  validates :gknn_cd, presence: true, inclusion: GknnCd::Map.keys,
            if: -> { Rails.env.teacher_production? }, on: :create
  validates :school, inclusion: { in: %w(s c k) }
  validates :experience_point, presence: true
  validates :level,            presence: true
  validates :viewing_time,     presence: true

  # define callbacks
  before_create do
    self.school = 'c'
    self.schoolbooks = Settings.default_schoolbooks_settings['c'].to_hash
  end

  before_save do |student|
    student.dialog_enabled = true if student.username == 'tutorial0001'
  end

  before_validation do
    if family_name_kana.present?
      self.family_name_kana = NKF.nkf('--katakana -w', family_name_kana)
    end

    if first_name_kana.present?
      self.first_name_kana = NKF.nkf('--katakana -w', first_name_kana)
    end
  end

  # @author hasumi
  # @since 20150603
  # 【ここ超重要です！】
  # パスワードは大文字小文字無視という仕様
  # 保存前にぜんぶ小文字にしちゃう
  before_validation do
    self.password = password.downcase if password.present?

    if password_confirmation.present?
      self.password_confirmation = password_confirmation.downcase
    end
  end

  # define delegate
  delegate :purchasable?, to: :parent
  delegate :new_user?, to: :parent

  # define state_machine
  state_machine :state, initial: :pending do
    after_transition on: :activate do |student, _|
      student.update_attributes current_month: Time.now.strftime('%Y%m').to_i
    end

    event :activate do
      transition pending: :active
    end

    event :deactivate do
      transition %i(active :pending) => :inactive
    end
  end

  # define devise
  # deviseの一部機能を拝借
  # これによってDevise標準のemailカラムではなくusernameカラムがログインIDになる
  devise :database_authenticatable,
         :trackable, authentication_keys: %i(username)

  # define class methods
  class << self
    def states
      %w(active pending inactive)
    end

    # @author hasumi
    # @since 20150519
    # 1st版認証を廃止して、Devise利用の認証を新規につくった
    def authenticate(params, request = nil)
      student = find_by(username: params['studentId'], state: 'active')
      if student.try(:valid_password?, params['password'].downcase)
        student.update_tracked_fields(request) if request.present?
        student
      else
        false
      end
    rescue => e
      raise e.class, e.message
    end

    def create_or_update_from_fist(parent_params, student_params, parent_password, student_password)
      ActiveRecord::Base.transaction do
        if (parent = Parent.find_by(email: parent_params[:email]))
          parent.skip_confirmation!

          parent_params = parent_params.slice(:kiyksh_cd,
                                              :family_name,
                                              :first_name,
                                              :family_name_kana,
                                              :first_name_kana)

          new_parent_password =
            parent.get_password(student_params[:ins_dt], parent_password)

          if parent.kiyksh_cd.present? && new_parent_password
            # 登録日がより最近の内部会員生徒アカウントが既に紐付いている場合
            parent.update!(parent_params.merge(password: new_parent_password))
          else
            parent.update!(parent_params)
          end
        else
          parent = Parent.new(parent_params.merge(password: parent_password))
          parent.skip_confirmation!
          parent.save!
        end

        if (student = parent.students.find_by(username: student_params[:username]))
          attrs = student_params.slice(:sit_cd,
                                       :gknn_cd,
                                       :current_member_type,
                                       :ins_dt,
                                       :family_name,
                                       :first_name,
                                       :family_name_kana,
                                       :first_name_kana,
                                       :birthday,
                                       :classroom,
                                       :private_flag)
          student.update!(attrs)
        else
          attrs = student_params.merge(password:              student_password,
                                       password_confirmation: student_password,
                                       parent:                parent)
          Student.create!(attrs)
        end
      end
    end
  end

  # define instance methods

  # @author hasumi
  # @since 20150612
  # ポイント上限を変更する
  def modify_upper_point_limit
    return true if following_monthly_point_was == following_monthly_point
    mailer_options = {}
    mailer_options[:following_monthly_point_was] = following_monthly_point_was
    mailer_options[:current_monthly_point_was] = current_monthly_point_was
    # ポイント引き上げの場合
    if following_monthly_point_was < following_monthly_point
      # 当月上限を即座に引き上げる場合
      if current_monthly_point < following_monthly_point
        self.current_monthly_point = following_monthly_point
      end
      # さらに「更新後の翌月上限」が「更新前の当月上限（その金額を与信確保済みのはず）」
      # より大きい場合に、その差額の与信確保処理をする
      if following_monthly_point > current_monthly_point_was
        diff = following_monthly_point - current_monthly_point_was
        amount = (diff * Settings.tax_rate).round
        unless ::Credit.reserve(parent: parent, amount: amount, student: self)
          return false
        end
      end
      save!
      if parent.upper_point_limit_modified
        ParentMailer.upper_point_limit_modified_increase(self, mailer_options)
                    .deliver
      end
      return true
    else
      # ポイント引き下げの場合
      save!
      if parent.upper_point_limit_modified
        ParentMailer.upper_point_limit_modified_reduction(self, mailer_options)
                    .deliver
      end
      return true
    end
  end

  def available_point
    self.current_monthly_point - self.spent_point
  end
  alias :current_total_point :available_point

  # 内部会員かどうかを判定するメソッド
  def fist?
    self.current_member_type == 'fist'
  end

  # @author hasumi
  # @since 20150522
  # 月末締めのポイント更新処理
  def update_point
    PointUpdateHistory.execute(self)
  end

  # @author hasumi
  # @since 20150519
  # 未読数を再計算
  def recount_unreads
    questions = self.questions.where(school: school)
    unreads   = if questions.blank?
                  0
                else
                  Post.where(postable_type: AdminUser.to_s,
                             state:         'accepted_unread',
                             question:      questions).size
                end
    update(unreads: unreads)
  end

  # @author tamakoshi
  # @since 20150612
  # ポイント上限設定しているかどうか
  def settings_point_limits?
    current_monthly_point != 0
  end

  # student.schoolbooks['info'] の中を更新するのは物凄く大変な為、
  # 後から追加された japanese_classics, japanese_chinese_classics に関してはハードコーディング
  def get_schoolbook_id(year, subject)
    if subject.end_with?('standard', 'high-level')
      Settings.default_schoolbooks_settings.c.info[year][subject].id
    elsif subject == 'japanese_classics'
      317
    elsif subject == 'japanese_chinese_classics'
      318
    else
      schoolbooks['info'][year][subject]['id']
    end
  end

  # @author hasumi
  # @since 20150603
  # 【ここ超重要です！】
  # パスワードは大文字小文字無視という仕様
  # Deviseの既存メソッドをオーバライド
  # https://github.com/plataformatec/devise/blob/master/lib/devise/
  # models/database_authenticatable.rb
  def valid_password?(password)
    # これがオリジナル
    # Devise::Encryptor.compare(self.class, encrypted_password, password)
    Devise::Encryptor.compare(self.class, encrypted_password,
                              password.try(:downcase))
  end

  # @author hasumi
  # @since 20150519
  # Devise::Models::Trackableからもってきてremote_ipのとこをgrape用に変更した
  def update_tracked_fields(request)
    old_current, new_current = current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current

    old_current = current_sign_in_ip
    new_current =
      request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR']
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1

    save
  end

  # @author tamakoshi
  # @since 20150624
  # 一旦c(中学生)で返す。
  # todo : 修正
  def school
    self[:school] || 'c'
  end

  def json
    self[:json] || { 'schoolyear' => 'c1', 'sit_smi' => 'テスト生徒' }
  end

  def schoolyear
    GknnCd::Map[gknn_cd]
  end

  # @author hasumi
  # @since 20150519
  def full_name
    [family_name, first_name].join(' ').strip
  end

  def full_name_kana
    [family_name_kana, first_name_kana].join(' ').strip
  end

  def update_schoolbooks(params)
    school = 'c'
    subjects = Subject.available_subjects(school)
    available_subject_name = subjects.map(&:name).uniq
    update_schoolbooks_settings_state(params, available_subject_name)
    array_of_schoolbooks = Schoolbook.includes(:subject)
                                     .where('year LIKE (?)', school + '%')
    schoolbooks['info'].each do |schoolyear, hash|
      hash.each do |subsubject, hash|
        subject_name, subject_type = subsubject.split('_')
        next if schoolyear == 'k'
        next if subject_type.in?(Subject::EXAM_LIST)
        next unless available_subject_name.include? subject_name
        subject = subjects.find do |subject|
          subject.name == subject_name && subject.type == subject_type
        end

        schoolbook_name, company_name =
          params.values.first[subject_name]['name'].split(/[（）]/)

        company_name ||= '' # 標準の場合companyは空文字列
        schoolbook = array_of_schoolbooks.find do |sb|
          sb.name == schoolbook_name &&
            sb.subject == subject &&
            sb.company == company_name &&
            sb.year == schoolyear.to_s
        end
        schoolbooks['info'][schoolyear][subsubject]['id'] = schoolbook.id
      end
    end
    save!
  end

  def update_schoolbooks_settings_state(params, available_subject_name)
    schoolbooks['settings_state'].each do |schoolyear, value|
      value.each do |subject, value|
        next unless available_subject_name.include? subject
        schoolbooks['settings_state'][schoolyear][subject] = true
      end
    end
  end

  def starred_videos_with_star(subject)
    schoolbook_ids = schoolbooks['info'].values.map { |sb| sb[subject]['id'] }
    current_schoolbook_video_ids = Schoolbook.where(id: schoolbook_ids)
                                             .flat_map(&:video_ids)
    blk = lambda do |star|
      video = star.video
      condition =
        video.subject.name_and_type == subject &&
        video.duplicated_count_num != 1 &&
        current_schoolbook_video_ids.include?(video.id)
      next unless condition
      { video: video, star: star }
    end

    stars.includes(video: [:video_title_image,
                           :video_subtitle_image,
                           :subject,
                           completes: :student,
                           incomprehensibles: :student])
         .map(&blk)
         .select(&:present?)
  end

  # 誕生日アクセサ
  def birthday_year
    birthday.try(:year) || Time.now.year - 14
  end

  def birthday_month
    birthday.try(:month) || 1
  end

  def birthday_day
    birthday.try(:day) || 1
  end

  # 性別アクセサ
  def sex_ja
    case sex
    when 'male'
      '男'
    when 'female'
      '女'
    else
      '未設定'
    end
  end

  # @author tamakoshi
  # @since 20150603
  # schoolbooksカラムが教科が増えたものになっているか確認にし
  # なっていなければデフォルトの設定を反映させる。
  def schoolbooks_settings_for_additional_subject
    additional_subject_name_and_type =
      Subject.available_subjects.map(&:name_and_type).uniq -
      schoolbooks['info'].values.flat_map(&:keys).uniq
    additional_subject_name =
      Subject.available_subjects.map(&:name).uniq -
      schoolbooks['settings_state'].values.flat_map(&:keys).uniq

    default_sb = Settings.default_schoolbooks_settings

    condition = additional_subject_name_and_type.present? &&
                Version.instance.switching_flag

    return true unless condition

    schoolbooks['info'].each do |schoolyear, _|
      select_block = lambda do |subject_name|
        additional_subject_name_and_type.include?(subject_name.to_s)
      end

      new_subject_schoolbooks_settings_info =
        default_sb[school]['info'][schoolyear].to_hash.select(&select_block)

      schoolbooks['info'][schoolyear].merge!(
        new_subject_schoolbooks_settings_info
      )
    end

    schoolbooks['settings_state'].each do |schoolyear, _|
      select_block = lambda do |subject_name|
        additional_subject_name.include?(subject_name.to_s)
      end

      new_subject_schoolbooks_settings_state =
        default_sb[school]['settings_state'][schoolyear].to_hash
                                                        .select(&select_block)
      schoolbooks['settings_state'][schoolyear].merge!(
        new_subject_schoolbooks_settings_state
      )
    end
    save!
  end

  # @author tamakoshi
  # @since 20150913
  def get_condition
    condition.try(:[], school) || Settings.default_condition[school].to_hash
  end

  # @author tamakoshi
  # @since 20150913
  def update_condition(params)
    self.condition = Settings.default_condition.to_hash unless condition
    self.condition[school]['year'] = params[:year]
    self.condition[school]['subject'] = params[:subject]
    save!
  end

  # typus向けアクセサメソッド
  def schoolbooks_settings_state
    schoolbooks['settings_state'].values[0].values.first == true
  end

  def parent_email_address
    parent.try(:email)
  end

  # @author tamakoshi
  # @since 20150914
  # カスタムバリデーション
  # FIST 新規作成API以外で, FISTの生徒番号及び社員IDが
  # usernameとして使用されるのを防ぐバリデーション。
  def username_cannot_be_fist_sitcd_at_parent
    if username.match(/\A\d{11}\z|\A\TS\d{4}\z/ )
      errors.add(:username, 'がすでに存在するため、このIDはご利用いただけません。'\
                            '別のIDをご利用ください。')
    end
  end

  # @author tamakoshi
  # @since 20150921
  # condition node のバリデーション
  def valid_condition
    return true unless condition.present?
    condition.each do |key, value|
      condition =
        value['year'].first == key &&
        value['subject'].in?(Subject::V3::SUBJECT_NAME_AND_TYPE[key])

      errors.add(:condition, ' is Invalid') unless condition
    end
  end

  # @author tamakoshi
  # 20151009
  # current_memberタイプを変える
  def change_member_type(type)
    if type == 'cancel'
      update!(current_member_type: sit_cd.present? ? 'fist' : 'tryit')
    else
      update!(current_member_type: type)
    end
  end

  # @author tamakoshi
  # @since 20160223
  # 一旦FISTユーザの場合はtrueにする
  # TODO: FIST APIを使用して先生と紐付いているかどうかを確認する
  def with_teacher?
    current_member_type.in?(%w(fist tester))
  end

  def unread_notification_num
    unread_news_num + unread_recommendation_num
  end

  def unread_news_num
    news_students.unreads.size
  end

  def unread_recommendation_num
    teacher_recommendations.notifiable.unreads.size
  end

  def self.to_csv_of_search
    attributes = %w(メールアドレス 学校の都道府県 住所の都道府県 学年 元の会員種別 作成日)

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.includes(:parent).find_each do |student|
        parent               = student.parent
        email                = parent.email
        school_address       = student.school_prefecture
        address              = parent.human_prefecture
        school_year          = GknnCd::Map[student.gknn_cd]
        original_member_type = student.original_member_type
        created_date         = student.created_at

        csv << [email, school_address, address, school_year, original_member_type, created_date]
      end
    end
  end

  def school_prefecture
    school_prefecture_code.present? ? JpPrefecture::Prefecture.find(school_prefecture_code).try(:name) : ''
  end

  def level_progress
    current_exp = Level.find_by(level: level).experience_point
    next_exp    = Level.find_by(level: level.succ).experience_point
    (experience_point - current_exp).to_f / (next_exp - current_exp).to_f * 100
  end

  def experience_point_for_next_level
    next_exp = Level.find_by(level: level.succ).experience_point
    (exp = next_exp - experience_point) <= 0 ? 0 : exp
  end

  private

  def only_fist_member_has_classroom_id
    errors.add(:classroom_id, :invalid) if classroom_id && !with_teacher?
  end
end
