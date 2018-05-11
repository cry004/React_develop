# == Schema Information
#
# Table name: fees
#
#  id            :integer          not null, primary key
#  admin_user_id :integer
#  paid_at       :date
#  point         :integer
#  shkkn_cd      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_fees_on_admin_user_id  (admin_user_id)
#
# Foreign Keys
#
#  fk_rails_3c54ee8d2a  (admin_user_id => admin_users.id)
#


class Fee < ActiveRecord::Base
  belongs_to :admin_user
  has_many :posts, dependent: :destroy
end
