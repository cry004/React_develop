# == Schema Information
#
# Table name: students
#
#  id                                 :integer          not null, primary key
#  sit_cd                             :string
#  json                               :json
#  school                             :string           default("c"), not null
#  schoolbooks                        :json
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  dialog_enabled                     :boolean          default(TRUE)
#  parent_id                          :integer
#  username                           :string           default(""), not null
#  encrypted_password                 :string           default(""), not null
#  sign_in_count                      :integer          default(0), not null
#  current_sign_in_at                 :datetime
#  last_sign_in_at                    :datetime
#  current_sign_in_ip                 :inet
#  last_sign_in_ip                    :inet
#  gknn_cd                            :string
#  school_name                        :string
#  family_name                        :string
#  first_name                         :string
#  family_name_kana                   :string
#  first_name_kana                    :string
#  sex                                :string
#  state                              :string
#  birthday                           :date
#  unreads                            :integer          default(0)
#  original_member_type               :string
#  current_member_type                :string
#  current_month                      :integer
#  it_login_kh_flag                   :string           default("1")
#  ins_dt                             :datetime
#  spent_point                        :integer          default(0)
#  current_monthly_point              :integer          default(0)
#  following_monthly_point            :integer          default(0)
#  school_prefecture_code             :integer
#  condition                          :json
#  access_token                       :string
#  my_box_first_seen                  :boolean          default(TRUE)
#  teacher_recommendations_first_seen :boolean          default(TRUE)
#  avatar                             :integer
#  nick_name                          :string
#  private_flag                       :boolean          default(TRUE), not null
#  experience_point                   :integer          default(0), not null
#  level                              :integer          default(1), not null
#  viewing_time                       :integer          default(0), not null
#  trophies_count                     :integer          default(0), not null
#  classroom_id                       :integer
#
# Indexes
#
#  index_students_on_classroom_id  (classroom_id)
#  index_students_on_parent_id     (parent_id)
#  index_students_on_sit_cd        (sit_cd) UNIQUE
#  index_students_on_username      (username) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0a4ac52d98  (level => levels.level)
#  fk_rails_4fde1dad9c  (classroom_id => classrooms.id)
#  fk_rails_d3631a714a  (parent_id => parents.id)
#

class Student::ProfileUpdator < ActiveType::Record[Student]
  require 'validations/ngword_validator'

  validates :avatar,
            presence:  true,
            inclusion: { in: (0..19) }

  validates :nick_name,
            presence: true,
            ngword:   true,
            length:   { in: 2..16, message: :length, min: 2, max: 16 }
end
