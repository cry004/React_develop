# == Schema Information
#
# Table name: admin_users
#
#  id                     :integer          not null, primary key
#  first_name             :string           default(""), not null
#  last_name              :string           default(""), not null
#  role                   :string           not null
#  email                  :string           not null
#  status                 :boolean          default(FALSE)
#  token                  :string           not null
#  password_digest        :string           not null
#  preferences            :string
#  created_at             :datetime
#  updated_at             :datetime
#  rank                   :string           default("bronze")
#  tel                    :string
#  first_name_kana        :string
#  last_name_kana         :string
#  password_reset_token   :string
#  password_reset_sent_at :datetime
#  current_month          :integer
#  kys_cd                 :string
#  birthday               :date
#
# Indexes
#
#  index_admin_users_on_email  (email) UNIQUE
#


class AdminUser < ActiveRecord::Base
  before_destroy :check_accepted_posts
  before_create :update_current_month
  include Typus::Orm::ActiveRecord::AdminUser
  has_many :posts, as: :postable, dependent: :destroy
  has_many :answer_questions, class_name: "Question", foreign_key: :answerer_id
  has_many :fees, dependent: :destroy
  scope :gatekeepers, -> { where(role: 'gatekeeper') }
  scope :executive_answerers, -> { where(role: 'executive_answerer') }
  scope :answerers, -> { where(role: 'answerer') }

  validates :tel, presence: true, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :tel, format: {with: /\A0\d{9,10}\z/}, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :first_name, presence: true, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :last_name, presence: true, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :first_name_kana, presence: true, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :last_name_kana, presence: true, if: Proc.new { |admin_user| admin_user.role == 'answerer' }
  validates :rank, inclusion: { in: %w(bronze silver gold) }

  attr_accessor :profile_update_mode
  validates :birthday, presence: true, if: Proc.new { |admin_user| profile_update_mode && admin_user.role == 'answerer' }
  before_save :update_kys_cd, if: Proc.new { |admin_user| profile_update_mode && admin_user.role == "answerer" && admin_user.kys_cd.blank? }

  # @author tamakoshi
  # @since 20150610
  # ランクとcurrent_monthの更新を行う。
  def exec_decide_answerer_rank
    base_month = Time.now.strftime("%Y%m").to_i
    self.set_rank(base_month) unless self.current_month == base_month
  end

  # @author tamakoshi
  # @since 20150610
  # ランク判定
  def judge_rank(posts_count = accepted_posts_at_prev_month_count)
    case posts_count
    when 0..100               then "bronze"
    when 101..300             then "silver"
    when 301..Float::INFINITY then "gold"
    end
  end

  # @author tamakoshi
  # @since 20151021
  # @param base_month [Integer] yyyymm
  # 先月の承認済み回答数を元にランクを設定
  def set_rank(base_month)
    self.update_attributes(rank: self.judge_rank, current_month: base_month)
  end

  # @author tamaskohi
  # @since 20151021
  # @param base_month_obj [Time]
  # ある月のランク
  def rank_at(base_month_obj)
    judge_rank(accepted_posts_at(base_month_obj.prev_month).count)
  end

  # @author tamakoshi
  # @since 20151022
  # @param base_month_obj [Time]
  # ある月の承認認みの回答を返す。
  def accepted_posts_at(base_month_obj)
    posts.accepted.where("accepted_at >= (?) AND accepted_at < (?)", base_month_obj.beginning_of_month, base_month_obj.next_month.beginning_of_month )
  end

  # @author tamakoshi
  # @since 20151022
  # 先月の承認認みの回答を返す
  def accepted_posts_at_prev_month
    accepted_posts_at(Time.now.prev_month)
  end

  # @author tamakoshi
  # @since 20151022
  # 先月の承認認みの回答数を返す
  def accepted_posts_at_prev_month_count
    accepted_posts_at_prev_month.count
  end

  # @author tamakoshi
  # @since 20151020
  # 未払い分のポイント数を返す。
  def unpaid_point
    unpaid_posts.map(&:fee_point).sum
  end

  def unpaid_posts
    posts.accepted.where(fee_id: nil)
  end

  # @author tamakoshi
  # @since 20151020
  # ポイントリクエスト可能かどうか
  def can_point_request?
    self.birthday.present? && (self.unpaid_point >= Settings.teacher_enable_point_request_limit) && self.kys_cd.present?
  end

  # @author tamakoshi
  # @since 20151020
  # ポイントリクエストの実行
  def exec_point_request
    # Fist APIの実行
    # API実行時点の未払いポイントをすべて換金する。
    shkkn_yti_ymd, shkkn_cd = Fist.post_teacher_point_request({ "KYS_CD" => self.kys_cd, "SHKKN_YTI_MNY" => unpaid_point })
    if shkkn_yti_ymd && shkkn_cd
      ActiveRecord::Base.transaction do
        fee = Fee.create!(admin_user: self, point: unpaid_point, paid_at: shkkn_yti_ymd, shkkn_cd: shkkn_cd)
        self.unpaid_posts.find_each do |post|
          post.update_attributes! fee: fee
        end
      end
    else
      raise "shkkn_yti_ymd and shkkn_cd are not present"
    end
  end

  # @author hasumi
  # @since 20150603
  def email_with_name
    "\"#{full_name}\" <#{email}>"
  end

  def full_name
    "#{last_name} #{first_name} 様"
  end

  # fist api用
  def kys_smi
    "#{last_name}#{first_name}"
  end

  # fist api用
  def kys_knsmi
    "#{last_name_kana}#{first_name_kana}"
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    TeacherAccountsMailer.reset_password_instructions(self).deliver_now
  end

  # 誕生日アクセサ
  def birthday_year
    self.birthday.try(:year) || Time.now.year - 14
  end

  def birthday_month
    self.birthday.try(:month)
  end

  def birthday_day
    self.birthday.try(:day)
  end

  private

  # @author hasumi
  # @since 20150603
  # typus/lib/typus/orm/active_record/admin_user.rb の同名メソッドをオーバライド
  def password_must_be_strong(count = 8)
    if !password.nil? && password.size < count
      errors.add(:password, :too_short, :count => count)
    end
  end

  # @author tamakoshi
  # @since 20150618
  # 削除する前に関連するpostがあるかどうかチェックし,あれば削除しない。
  def check_accepted_posts
    false if self.posts.present?
  end

  # @author tamakoshi
  # @since 20150807
  # 作成前にcurrent_monthを更新する
  def update_current_month
    self[:current_month] = Time.now.strftime("%Y%m").to_i
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(64)
    end while AdminUser.exists?(column => self[column])
  end

  # @author tamakoshi
  # @since 20151021
  def update_kys_cd
    kys_cd_from_fist = Fist.get_kys_cd({
                         "KYS_SMI"        => kys_smi,
                         "KYS_KNSMI"      => kys_knsmi,
                         "BIRTH_DATE_YMD" => birthday.strftime("%Y%m%d"),
                         "TEL_NO"         => tel,
                         "MAIL"           => email
                       })
    kys_cd_from_fist.present? ? (self.kys_cd = kys_cd_from_fist) : (raise "kys_cd is not present")
  end
end
