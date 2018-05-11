# == Schema Information
#
# Table name: student_avatars
#
#  id             :integer          not null, primary key
#  teacher_id     :integer          not null
#  student_sit_cd :string           not null
#  color          :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  code           :string           not null
#  sex            :string           not null
#
# Indexes
#
#  index_student_avatars_on_student_sit_cd  (student_sit_cd)
#  index_student_avatars_on_teacher_id      (teacher_id)
#


class StudentAvatar < ActiveRecord::Base
  def readonly?
    true
  end

  # 自立学習コースでは男・女・ユニセックスで1色ずつのみ
  def self.get_url_for_learning(student)
    base_url = Settings.student_avatar.base_url
    sex      = student.sex || 'unisex'
    "#{base_url}#{sex}_1_paleblue_bg_gray_large.png"
  end
end
