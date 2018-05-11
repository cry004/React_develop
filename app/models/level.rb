# == Schema Information
#
# Table name: levels
#
#  id               :integer          not null, primary key
#  level            :integer          not null
#  experience_point :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_levels_on_experience_point  (experience_point) UNIQUE
#  index_levels_on_level             (level) UNIQUE
#

class Level < ActiveRecord::Base
  validates :level, presence:   true,
                    uniqueness: true
  validates :experience_point, presence:   true,
                               uniqueness: true
end
