# == Schema Information
#
# Table name: schools
#
#  id               :integer          not null, primary key
#  k_code           :string
#  name             :string
#  kana             :string
#  prefecture_code  :integer
#  japanese_book    :string
#  mathematics_book :string
#  english_book     :string
#  science_book     :string
#  geography_book   :string
#  history_book     :string
#  civics_book      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category         :string
#


class School < ActiveRecord::Base
end
