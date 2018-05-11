# == Schema Information
#
# Table name: e_navis
#
#  id              :integer          not null, primary key
#  fist_subject_id :integer          not null
#  section_id      :integer          not null
#  section_name    :string           not null
#  content_id      :integer          not null
#  content_name    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_e_navis_identity  (fist_subject_id,section_id,content_id) UNIQUE
#


class ENavi < ActiveRecord::Base
  has_many :e_navi_sub_units
  has_many :sub_units, through: :e_navi_sub_units
end
