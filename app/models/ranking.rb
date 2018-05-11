# == Schema Information
#
# Table name: rankings
#
#  id         :integer          not null, primary key
#  type       :string           not null
#  date       :date             not null
#  period_day :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_rankings_on_type_and_date_and_period_day  (type,date,period_day) UNIQUE
#

class Ranking < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  TYPES = [Student, Classroom::Klassroom, Classroom::Schoolhouse].map(&:name)

  has_many :ranks, dependent: :destroy

  scope :recent, -> { order(date: :desc) }
  scope :students, -> { where(type: Student.name) }
  scope :classrooms, -> { where(type: Classroom::Klassroom.name) }
  scope :schoolhouses, -> { where(type: Classroom::Schoolhouse.name) }

  validates :type,       presence:   true,
                         uniqueness: { scope: %i(date period_day) },
                         inclusion:  { in: TYPES }
  validates :date,       presence:   true
  validates :period_day, presence:   true

  def aggregation_start_date
    date - period_day.days
  end

  def aggregation_end_date
    date.yesterday
  end

  def last_month
    date.last_month.month
  end

  # Don't save this class's instance directly.
  private :save, :save!, :update, :update!, :update_attributes, :update_attributes!
end
