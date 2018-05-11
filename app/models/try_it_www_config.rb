# == Schema Information
#
# Table name: try_it_www_configs
#
#  id              :integer          not null, primary key
#  mypage_503_flag :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class TryItWwwConfig < ActiveRecord::Base
  acts_as_singleton
end
