# == Schema Information
#
# Table name: chiefs
#
#  id             :integer          not null, primary key
#  access_token   :string
#  one_time_token :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shin_cd        :string
#  classroom_id   :integer
#
# Indexes
#
#  index_chiefs_on_access_token  (access_token)
#  index_chiefs_on_classroom_id  (classroom_id)
#  index_chiefs_on_shin_cd       (shin_cd) UNIQUE
#
# Foreign Keys
#
#  fk_rails_250704d5ce  (classroom_id => classrooms.id)
#

class Chief::Plus < ActiveType::Record[Chief]
  has_one :classroom

  # TODO: Change this to default_scope { where(type: 1) } after adding 'type' column
  default_scope { where.not(classroom_id: nil) }

  validates :classroom_id, presence: true, uniqueness: true
end
