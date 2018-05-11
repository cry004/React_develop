# == Schema Information
#
# Table name: e_navi_sub_units
#
#  id          :integer          not null, primary key
#  e_navi_id   :integer          not null
#  sub_unit_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_e_navi_sub_units_on_e_navi_id    (e_navi_id)
#  index_e_navi_sub_units_on_sub_unit_id  (sub_unit_id)
#
# Foreign Keys
#
#  fk_rails_716004b9df  (e_navi_id => e_navis.id)
#  fk_rails_8aeea535f3  (sub_unit_id => sub_units.id)
#


class ENaviSubUnit < ActiveRecord::Base
  belongs_to :e_navi
  belongs_to :sub_unit
end
