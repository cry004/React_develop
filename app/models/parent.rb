# == Schema Information
#
# Table name: parents
#
#  id                         :integer          not null, primary key
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  reset_password_token       :string
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0), not null
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :inet
#  last_sign_in_ip            :inet
#  confirmation_token         :string
#  confirmed_at               :datetime
#  confirmation_sent_at       :datetime
#  unconfirmed_email          :string
#  family_name                :string
#  first_name                 :string
#  family_name_kana           :string
#  first_name_kana            :string
#  zip                        :string
#  prefecture_code            :integer
#  address1                   :string
#  address2                   :string
#  tel                        :string
#  sex                        :string
#  state                      :string
#  created_at                 :datetime
#  updated_at                 :datetime
#  city                       :string
#  relationship_code          :integer
#  kiyksh_cd                  :string
#  creditcard                 :boolean
#  domestic                   :boolean          default(TRUE)
#  foreign_address            :string
#  upper_point_limit_modified :boolean          default(FALSE)
#
# Indexes
#
#  index_parents_on_confirmation_token    (confirmation_token) UNIQUE
#  index_parents_on_email                 (email) UNIQUE
#  index_parents_on_reset_password_token  (reset_password_token) UNIQUE
#

class Parent < ActiveRecord::Base
  include Billing # concern

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable,
         password_length: Rails.env.include?('teacher') ? (4..255) : (8..255)

  has_many :students, dependent: :destroy
  accepts_nested_attributes_for :students, reject_if: :all_blank, allow_destroy: false, limit: 5
  has_many :orders, as: :orderable, dependent: :destroy
  has_many :cart_items, as: :checkoutable, dependent: :destroy
  has_many :sbps_logs

  validates :first_name, presence: true, on: :update
  validates :family_name_kana, presence: true, on: :update
  validates :family_name_kana, format: { with: /\A[.ァ-ヾ]+\z/}, on: :update
  validates :first_name_kana, presence: true, on: :update
  validates :first_name_kana, format: { with: /\A[.ァ-ヾ]+\z/}, on: :update
  validates :family_name, presence: true, on: :update
  attr_accessor :update_mode #登録後のregistrations#udateでパスワードバリデーションをキャンセルするための小細工
  validates :password, presence: true, length: { minimum: 8, maximum: 255 },
            on: :update, if: ->{ update_mode == 'confirmation' || update_mode == 'edit_password'}
  validates :password, presence: true, on: :create, if: -> { Rails.env.include?('teacher') }
  validates_confirmation_of :password
  validates :zip, presence: true, on: :update              , if: -> { domestic && %w(user_withdrawal).exclude?(update_mode) }
  validates :zip, format: { with: /\A\d{3}-?\d{4}\z/}, on: :update, if: -> { domestic && %w(user_withdrawal).exclude?(update_mode) }
  validates_inclusion_of :domestic, in: [true, false]
  validates :prefecture_code, presence: true, on: :update, if: -> { domestic && %w(user_withdrawal).exclude?(update_mode) }
  validates :city, presence: true, on: :update           , if: -> { domestic && %w(user_withdrawal).exclude?(update_mode) }
  validates :address1, presence: true, on: :update       , if: -> { domestic && %w(user_withdrawal).exclude?(update_mode) }
  validates :foreign_address, presence: true, on: :update, unless: -> { domestic }
  validates :tel, presence: true, on: :update, if: -> { %w(user_withdrawal).exclude?(update_mode)}
  validates :relationship_code, presence: true, on: :update, if: -> { %w(user_withdrawal).exclude?(update_mode)}

  include JpPrefecture
  jp_prefecture :prefecture_code

  default_scope {includes(:students)}

  state_machine :state, initial: :active do
    event :deactivate do
      transition [nil, :active] => :inactive
    end
  end

  NESSESARY_ATTRS_FOR_PURCHASE = %w(zip prefecture_code city address1 tel)

  # @author hasumi
  # @since 20150716
  # いままでに一度でもクレカ登録をしたことがないか？。ないならtrue
  def creditcard_never_modified?
    self.creditcard.nil?
  end

  # @author hasumi
  # @since 20150603
  # 【ここ超重要です！】
  # パスワードは大文字小文字無視という仕様
  # 保存前にぜんぶ小文字にしちゃう
  before_validation do
    self.password = password.downcase if password.present?
    self.password_confirmation = password_confirmation.downcase if password_confirmation.present?
  end

  # 生徒Ａ（兄・現学年 中２）：トライとの契約が2014/10/13、トライイットと連携がなされていない
  #                            （2015年時点で小６のため、トライイットサービスイン時に連携対象としていない）
  # 生徒Ｂ（弟・現学年 中１）：トライとの契約が2017/07/13、トライイットと連携完了済み
  # 上記のようなケースで生徒Ａを2017/07/24にトライイット連携した場合、保護者のパスワードをトライMyPageに合わせる
  def get_password(ins_dt, kiyksh_password)
    first_register_student_ins_dt = students.order("ins_dt").first.try(:ins_dt)
    if first_register_student_ins_dt && (first_register_student_ins_dt > ins_dt)
      kiyksh_password.downcase
    else
      false
    end
  end

  # @author tamakoshi
  # @since 20150615
  def email_with_name
    "\"#{full_name}\" <#{email}>"
  end

  # @author tamakoshi
  # @since 20150619
  def full_name
    "#{family_name} #{first_name} 様"
  end

  # @author hasumi
  # @since 20150713
  # 退会処理
  def withdraw!
    self.update_mode = 'user_withdrawal'
    ActiveRecord::Base.transaction do
      self.students.each do |student|
        student.deactivate!
        student.update_attributes! following_monthly_point: 0
      end
      self.email = "#{self.email}+#{Time.now.to_i.to_s}"
      self.skip_reconfirmation! # 無理やり書き換えたemailにメールを送ろうとするのを阻止
      self.save!(validate: false)
      self.deactivate!
    end
  end

  def human_zip
    if self.zip.present?
      no_hyphen_zip = self.zip.gsub("-", "")
      no_hyphen_zip[0..2] + '-' + no_hyphen_zip[3..6]
    end
  end

  # typus用
  def human_prefecture
    prefecture_code.present? ? JpPrefecture::Prefecture.find(prefecture_code).try(:name) : ""
  end

  def human_creditcard
    creditcard ? "◯" : "☓"
  end

  def human_domestic
    domestic ? "国内" : "海外"
  end

  # @author hasumi
  # @since 20150603
  # 【ここ超重要です！】
  # パスワードは大文字小文字無視という仕様
  # Deviseの既存メソッドをオーバライド。。。
  # https://github.com/plataformatec/devise/blob/master/lib/devise/models/database_authenticatable.rb
  def valid_password?(password)
    # Devise::Encryptor.compare(self.class, encrypted_password, password) ←これがオリジナル
    Devise::Encryptor.compare(self.class, encrypted_password, password.try(:downcase))
  end

  after_update do
    # はじめてポイント上限を設定した
    if !upper_point_limit_modified_was && upper_point_limit_modified
      ParentMailer.upper_point_limit_modified_for_the_first_time(self).deliver
    end
  end

  # @author hasumi
  # @since 20150611
  # 生徒が使えるポイントの上限を変更する
  def modify_upper_point_limit(parent_params)
    # student.id改竄対策（ほんとに必要かどうかわかんないけど）
    return false if self.students.map(&:id).sort != parent_params[:students_attributes].values.map{|param| param['id'].to_i}.sort
    # ここから本処理
    self.assign_attributes parent_params
    if self.students.all? {|student| student.modify_upper_point_limit}
      self.update_attribute :upper_point_limit_modified, true
    else
      false
    end
  end

  # @author hasumi
  # @since 20150526
  # よくあるこれ
  # http://beyond.cocolog-nifty.com/akutoku/2011/05/rails-a0d6.html
  validates_acceptance_of :confirming
  after_validation :check_confirming
  def check_confirming
    errors.delete( :confirming )
    self.confirming = errors.empty? ? '1' : ''
  end

  # @author hasumi
  # @since 20150526
  # 登録の最初のステップでPWを不要にするための改修
  # https://github.com/plataformatec/devise/wiki/How-To:-Email-only-sign-up
  def password_required?
    super if confirmed?
  end

  # @author hasumi
  # @since 20150526
  # 登録の最初のステップでPWを不要にするための改修
  # https://github.com/plataformatec/devise/wiki/How-To:-Email-only-sign-up
  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

  # @author hasumi
  # @since 20150527
  # サインアップフローでつかう。保護者が選択したのと同じ数のstudentをそろえる
  def create_or_destroy_students(students_count)
    raise unless (1..5).include?(students_count)
    pending_students_count = pending_students.count
    if pending_students_count < students_count
      (students_count - pending_students_count).times do
        username = uniq_student_username
        Student.create! parent: self,
          original_member_type: 'tryit',
          current_member_type: 'tryit',
          username: username,
          password: username, # 仮のパスワード
          schoolbooks: Settings.default_schoolbooks_settings["c"].to_hash
      end
    elsif pending_students_count > students_count
      self.students.where(state: 'pending').order('id DESC').limit(pending_students_count - students_count).destroy_all
    end
    self.pending_students.first
  end

  def creditcard_destroyable?
    self.students.all?{|student| student.current_monthly_point == 0}
  end

  # @author hasumi
  # @since 20150527
  def pending_students
    self.students.where(state: 'pending').order(:id)
  end

  def halfway_signup?
    self.any_pending_student? || self.students.blank?
  end

  def any_pending_student?
    self.students.where(state: 'pending').present?
  end

  # @author tamakoshi
  # @since 20160220
  # @return [Boolean]
  def purchasable?
    purchasable_at_domestic? || purchasable_at_foreign?
  end

  # @author tamakoshi
  # @since 20150220
  def purchasable_at_domestic?
    if domestic
      nessesary_attrs_for_purchase.all? do |attr, value|
        value.present?
      end
    else
      false
    end
  end

  # @author tamakoshi
  # @since 20150220
  def purchasable_at_foreign?
    !domestic && foreign_address.present?
  end

  # @author tamakoshi
  # @since 20150220
  def nessesary_attrs_for_purchase
    attributes.select do |attr, value|
      attr.to_s.in?(NESSESARY_ATTRS_FOR_PURCHASE)
    end
  end

  # @author tamakoshi
  # @since 20160229
  # 新規会員登録フローをリリースした後で登録してかつFIST会員ではないユーザは
  # new_userとして扱われる
  def new_user?
    new_user_date  = Time.zone.parse(Settings.new_user_date)
    register_dates = [created_at, confirmed_at, confirmation_sent_at].compact
    register_dates.any? { |date| new_user_date <= date } && kiyksh_cd.blank?
  end

  private

  # @author hasumi
  # @since 20150527
  # サインアップフローの途中でstudentを一時的に保存するためのユニークなusernameをつくる
  def uniq_student_username
    self.email + '_' + SecureRandom.uuid
  end
end
