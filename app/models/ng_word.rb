# == Schema Information
#
# Table name: ng_words
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NgWord < ActiveRecord::Base
end
