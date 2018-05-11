# == Schema Information
#
# Table name: teachers
#
#  id              :integer          not null, primary key
#  kys_cd          :string           not null
#  first_name      :string
#  last_name       :string
#  first_name_kana :string
#  last_name_kana  :string
#  tokens          :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  sex             :string           default("unisex"), not null
#
# Indexes
#
#  index_teachers_on_kys_cd  (kys_cd)
#


class Teacher < ActiveRecord::Base
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :teacher_recommendations, dependent: :destroy

  # @author tamakoshi
  # @since 20160209
  def honorific_name
    "#{last_name}先生"
  end
end
