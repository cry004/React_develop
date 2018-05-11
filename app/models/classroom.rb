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

class Classroom < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  MIN_TMP_CD_LENGTH = 4  # prescribed by FIST
  MAX_TMP_CD_LENGTH = 4  # prescribed by FIST
  MIN_NAME_LENGTH   = 1  # prescribed by FIST
  MAX_NAME_LENGTH   = 70 # prescribed by FIST

  module TYPE
    CLASSROOM = 'classroom'
    SCHOOLHOUSE = 'schoolhouse'
  end

  scope :group_by_pref_code, -> { group('classrooms.prefecture_code') }

  has_many :ranks, as: :ranker, dependent: :destroy
  has_many :students
  has_one :chief

  validates :tmp_cd, presence:   true,
                     length:     { in: MIN_TMP_CD_LENGTH..MAX_TMP_CD_LENGTH },
                     uniqueness: { scope: :type }
  validates :name,   presence:   true,
                     length:     { in: MIN_NAME_LENGTH..MAX_NAME_LENGTH }
  validates :type,   presence:   true
  validates :prefecture_code, presence:  true,
                              inclusion: { in: JpPrefecture::Prefecture.all.map(&:code) }
  validates :status,          presence:  true
  validates :color_number,    presence:  true

  def classroom_type
    case type
    when *Classroom::Klassroom::GYTI_KBN   then Classroom::TYPE::CLASSROOM
    when *Classroom::Schoolhouse::GYTI_KBN then Classroom::TYPE::SCHOOLHOUSE
    end
  end

  def prefecture_name
    JpPrefecture::Prefecture.find(prefecture_code)&.name
  end

  # Don't save this class's instance directly.
  private :save, :save!, :update, :update!, :update_attributes, :update_attributes!
end
