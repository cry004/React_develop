# == Schema Information
#
# Table name: sub_units
#
#  id              :integer          not null, primary key
#  unit_id         :integer
#  name            :string
#  sort            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sub_unit_number :integer          default(0), not null
#
# Indexes
#
#  index_sub_units_on_unit_id  (unit_id)
#


class SubUnit < ActiveRecord::Base
  belongs_to :unit

  has_many :e_navi_sub_units
  has_many :e_navis, through: :e_navi_sub_units
  has_many :learnings
  has_many :sub_unit_videos
  has_many :videos, through: :sub_unit_videos
end
