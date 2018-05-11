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

class Ranking::Daily < ActiveType::Record[Ranking]
  PERIOD_DAYS = [7]

  default_scope -> { where(period_day: PERIOD_DAYS) }

  validates :period_day, inclusion: { in: PERIOD_DAYS }

  def self.generate!(date)
    TYPES.product(PERIOD_DAYS).map do |type, day|
      create!(type: type, date: date, period_day: day)
    end
  end

  public :save, :save!, :update, :update!, :update_attributes, :update_attributes!
end
