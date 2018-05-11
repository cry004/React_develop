# == Schema Information
#
# Table name: sbps_logs
#
#  id                 :integer          not null, primary key
#  parent_id          :integer
#  amount             :integer
#  request_method     :string
#  credit_id          :integer
#  request            :xml
#  response           :xml
#  result             :string
#  sps_transaction_id :string
#  tracking_id        :string
#  err_code           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_sbps_logs_on_credit_id  (credit_id)
#  index_sbps_logs_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_45d5ff934e  (credit_id => credits.id)
#  fk_rails_8046e06933  (parent_id => parents.id)
#


class SbpsLog < ActiveRecord::Base
  belongs_to :parent
  belongs_to :credit
end
