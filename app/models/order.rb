# == Schema Information
#
# Table name: orders
#
#  id                      :integer          not null, primary key
#  total_point             :integer
#  state                   :string
#  memo                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  orderable_type          :string
#  orderable_id            :integer
#  category                :string
#  settled_at              :datetime
#  english_schoolbook_code :integer
#


class Order < ActiveRecord::Base
  belongs_to :orderable, polymorphic: true
  has_many :line_items, dependent: :destroy
  has_many :sbps_logs
  has_one :credit

  validates :orderable, presence: true
  validates :line_items, presence: true

  # 今月の確定分(current_monthはYYYYMM形式のinteger)
  scope :settled_current_month_order, ->(current_month, next_month) do
    current_month_begging_day = Time.new(current_month.to_s[0..3].to_i, current_month.to_s[4..5].to_i)
    next_month_begging_day = Time.new(next_month.to_s[0..3].to_i, next_month.to_s[4..5].to_i)
    where("created_at >= (?) AND created_at < (?) AND state = (?)", current_month_begging_day, next_month_begging_day, "settled")
  end

  # ordered: 中学英語テスト対策編が含まれており発送不可 / 回答承認前
  state_machine :state, initial: :ordered do
    #キャンセルに伴う返ポイント処理
    after_transition [:ordered, :settled, :unsettled] => :canceled do |order, transition|
      creditor = order.orderable
      if creditor.class.to_s == 'Student' && !order.extend_to_the_next_month?
        creditor.spent_point = creditor.spent_point - order.total_point
        creditor.save
      end
      order.update_attributes(total_point: 0)
    end

    after_transition [:ordered, :unsettled] => :settled do |order, transition|
      order.update_attributes! settled_at: Time.now
    end

    after_transition :settled => [:ordered, :unsettled] do |order, transition|
      order.update_attributes! settled_at: nil
    end

    after_transition :unsettled => :ordered do |order, transition|
      order.update_attributes! english_schoolbook_code: nil
    end

    # （問題集購入のみ）中学英語テスト対策編が含まれていないかまたは教科書特定済みで発送可
    event :unsettle do
      transition [:ordered] => :unsettled
    end

    # 発送可を発送不可にする
    event :return_ordered do
      transition [:unsettled] => :ordered
    end

    # 発送済み / 回答承認済み
    event :settle do
      transition [:ordered, :unsettled, :suspended] => :settled
    end

    # 発送済み を 発送可に戻す
    event :return_unsettled do
      transition [:settled] => :unsettled
    end

    # 確定決済を保留中
    event :suspend do
      transition [:settled] => :suspended
    end
    # 購入キャンセル / 回答遅れorやり直しで返ポイント
    event :cancel do
      transition [:ordered, :unsettled] => :canceled
    end
    # （問題集購入のみ）問題集を注文したが与信失敗
    event :failure do
      transition [:ordered, :unsettled] => :failed
    end
    # 確定決済が成功
    event :collect do
      transition [:settled, :uncollected] => :collected
    end
    # 確定決済が失敗
    event :uncollect do
      transition [:settled] => :uncollected
    end
  end

  before_create do
    check_availability
  end

  after_create do
    if self.orderable.class.to_s == 'Student' # Parentの場合は別途つくる
      check_wallet
      withdraw
    end
    devide_initial_state
  end

  scope :settleds, -> { where(state: 'settled') }
  scope :ordereds_and_settleds, -> { where(state: ['ordered', 'settled']) }

  # 今月の確定分(current_monthはYYYYMM形式のinteger)
  scope :settled_current_month_order, ->(current_month, next_month) do
    current_month_begging_day = Time.new(current_month.to_s[0..3].to_i, current_month.to_s[4..5].to_i)
    next_month_begging_day = Time.new(next_month.to_s[0..3].to_i, next_month.to_s[4..5].to_i)
    where("created_at >= (?) AND created_at < (?) AND state = (?)", current_month_begging_day, next_month_begging_day, "settled")
  end

  # @author hasumi
  # @since 20150521
  # @param [Student/Parent] orderable
  # @param [Array/ActiveRelation] products
  def self.execute(orderable, products)
    Order.transaction do
      order = Order.new(orderable: orderable)
      LineItem.transaction do
        order.line_items = products.map do |product|
          LineItem.create!(product: product, order: order, quantity: 1) # 20150819 ここだけ最低限の改修（quantity: 1の部分）
        end
        order.total_point = order.line_items.map(&:point).sum
        order.category = order.line_items.first.product.category
      end
      order.save!
      return order
    end
  end

  # @author hasumi
  # @since 20150819
  # @param [Student/Parent] orderable
  # @param [Array/ActiveRelation] cart_items
  # 保護者側にカート機能をつくるために別メソッドを切った。
  # executeがproductsを受け取るのに対し、こちらはcart_itemsを受け取る
  # そのうちexecuteと統合？
  def self.checkout(orderable, cart_items)
    Order.transaction do
      order = Order.new(orderable: orderable)
      LineItem.transaction do
        order.line_items = cart_items.map do |cart_item|
          LineItem.create!(product: cart_item.product, order: order, quantity: cart_item.quantity)
        end
        order.category = cart_items.first.product.category
        LineItem.create!(product: ShippingFee.product(order.line_items), order: order, quantity: 1)
        order.reload.total_point = order.line_items.map(&:point).sum
      end
      order.save!
      return order
    end
  end

  # @author tamakoshi
  # @since 20150617
  # 質問返ポイント時に月をまたいでいるかどうかをチェックする。
  def extend_to_the_next_month?
    (line_items.first.product.category == "question") && (created_at.month != Time.now.month)
  end

  # typus用メソッド
  def orderable_email
    (orderable.class.to_s == "Parent") ? orderable.email : orderable.parent.email
  end

  def orderable_tel
    (orderable.class.to_s == "Parent") ? orderable.tel : orderable.parent.tel
  end

  def student
    (orderable.class.to_s == "Parent") ? orderable.students.first : orderable
  end

  def parent
    (orderable.class.to_s == "Parent") ? orderable : orderable.parent
  end

  def customer_id
    sbps = SBPS::Base.new
    sbps.instance_variable_set "@parent", self.parent
    sbps.send(:cust_code)
  end

  def schoolbook_name
    Settings.english_schoolbook_code.to_hash.invert[english_schoolbook_code].to_s
  end

  def data_for_csv
    array = Array.new(LineItem::OrderCSVMap.count, 0)
    line_items.includes(:product).each do |item|
      next if item.original_name.nil?
      index_num = LineItem::OrderCSVMap[item.original_name]
      array[index_num] += item.quantity
    end
    array
  end

  def credit_id
    credit.try!(:id)
  end

  def must_set_english_schoolbook_code?
    self.line_items.any? {|line_item| line_item.product.subject_full_name == "english_exam" }
  end

  # @author tamakoshi
  # @override
  def can_settle?
    if self.category == "question"
      super
    else
      self.state.in? %w(unsettled suspended)
    end
  end

  private

  # @author hasumi
  # @since 20150521
  def check_availability
    unless self.line_items.all?{ |line_item| line_item.product.onsale? }
      raise Exceptions::ProductAvailabilityError
    end
  end

  # @author hasumi
  # @since 20150528
  def check_wallet
    if self.line_items.map(&:point).sum > self.orderable.available_point
      raise Exceptions::CurrentPointShortageError
    end
  end

  # @author hasumi
  # @since 20150528
  # Student(orderable)の課金ポイント残高から買い物した分を引き出す
  def withdraw
    debtor = self.orderable
    debtor.spent_point += self.total_point
    debtor.save
  end

  # @author tamakoshi
  # @since 20151019
  # textbookの購入で英語テスト対策編(中学版)が含まれている場合stateをorderedのままにする
  def devide_initial_state
    if self.category == "textbook" && self.line_items.none? {|line_item| line_item.product.subject_full_name == "english_exam" }
      self.unsettle
    end
  end
end
