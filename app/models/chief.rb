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

class Chief < ActiveRecord::Base
  # TODO: Delete these validations if those of Chief::Fist and Chief::Plus seem to work
  validates :classroom_id, presence: true, uniqueness: true, if: -> { shin_cd.blank? }
  validates :shin_cd, presence: true, uniqueness: true, if: -> { classroom_id.blank? }
end

require_dependency 'chief/fist'
require_dependency 'chief/plus'
