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

class Period::Fist < ActiveType::Record[Period]
  GYTI_KBN = Classroom::Fist::GYTI_KBN

  default_scope { where(type: GYTI_KBN) }
  validates :type, inclusion: { in: GYTI_KBN }
end
