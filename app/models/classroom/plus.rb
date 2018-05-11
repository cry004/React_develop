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

class Classroom::Plus < ActiveType::Record[Classroom]
  GYTI_KBN = %w(70)    # prescribed by FIST (70: トライプラス)
  TMP_STS  = %w(0 1 2) # prescribed by FIST (0: CLOSE, 1: OPEN, 2: PREPARE)
  COLORS   = [5, 6]

  default_scope { where(type: GYTI_KBN) }
  before_validation :set_color

  validates :type,   inclusion: { in: GYTI_KBN }
  validates :status, inclusion: { in: TMP_STS }
  validates :color_number,  inclusion: { in: COLORS }

  public :save, :save!, :update, :update!, :update_attributes, :update_attributes!

  private

  def set_color
    self.color_number = COLORS.sample
  end
end
