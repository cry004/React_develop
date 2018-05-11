# == Schema Information
#
# Table name: periods
#
#  id            :integer          not null, primary key
#  str_period_id :string           not null
#  start_time    :time             not null
#  end_time      :time             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  type          :string           default("01"), not null
#
# Indexes
#
#  index_periods_on_str_period_id_and_type  (str_period_id,type) UNIQUE
#

class Period < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  MIN_STR_PERIOD_ID_LENGTH = 2  # prescribed by FIST
  MAX_STR_PERIOD_ID_LENGTH = 2  # prescribed by FIST

  has_many :curriculums
  has_many :learning_reports
  has_many :learnings

  validates :str_period_id, presence: true,
                            length: { in: MIN_STR_PERIOD_ID_LENGTH..MAX_STR_PERIOD_ID_LENGTH },
                            uniqueness: { scope: :type }
  validates :type, presence: true

  def self.of(type)
    case type
    when *Period::Fist::GYTI_KBN then Period::Fist
    when *Period::Plus::GYTI_KBN then Period::Plus
    end
  end

end

require_dependency 'period/fist'
require_dependency 'period/plus'
