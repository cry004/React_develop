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

class Classroom::Fist < ActiveType::Record[Classroom]
  GYTI_KBN = %w(01 02) # prescribed by FIST (01: 家庭, 02: 個別)
  TMP_STS  = %w(01 02) # prescribed by FIST (01: OPEN, 02: CLOSE)
  CLASSROOM_COLORS  = [0, 1, 2, 3, 4]
  SHOOLHOUSE_COLORS = [7, 8, 9, 10, 11]
  COLORS   = CLASSROOM_COLORS + SHOOLHOUSE_COLORS

  default_scope { where(type: GYTI_KBN) }
  before_validation :set_color

  validates :type,   inclusion: { in: GYTI_KBN }
  validates :status, inclusion: { in: TMP_STS }
  validates :color_number,  inclusion: { in: COLORS }

  public :save, :save!, :update, :update!, :update_attributes, :update_attributes!

  private

  def set_color
    case type
    when '01'
      self.color_number = SHOOLHOUSE_COLORS.sample
    when '02'
      self.color_number = CLASSROOM_COLORS.sample
    end
  end
end
