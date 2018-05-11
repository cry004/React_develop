# == Schema Information
#
# Table name: classrooms
#
#  id              :integer          not null, primary key
#  tmp_cd          :string           not null
#  name            :string           not null
#  type            :string           not null
#  prefecture_code :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  status          :string           not null
#  color_number    :integer          not null
#
# Indexes
#
#  index_classrooms_on_tmp_cd_and_type  (tmp_cd,type) UNIQUE
#

class Classroom::Schoolhouse < ActiveType::Record[Classroom]
  GYTI_KBN = %w(01) # prescribed by FIST (01: 家庭)

  default_scope { where(type: GYTI_KBN) }

  scope :status_available, -> { where(status: '01') }
end
