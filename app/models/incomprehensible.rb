# == Schema Information
#
# Table name: incomprehensibles
#
#  id          :integer          not null, primary key
#  student_id  :integer
#  video_id    :integer
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :integer
#
# Indexes
#
#  index_incomprehensibles_on_question_id  (question_id)
#  index_incomprehensibles_on_student_id   (student_id)
#  index_incomprehensibles_on_video_id     (video_id)
#
# Foreign Keys
#
#  fk_rails_6d5ff34bf8  (video_id => videos.id)
#  fk_rails_adfaae3b79  (student_id => students.id)
#


class Incomprehensible < ActiveRecord::Base
  belongs_to :student
  belongs_to :video
  belongs_to :question

  # 管理者画面用
  def video_filename
    video.filename
  end

  def student_sit_cd
    student.sit_cd
  end

  def student_name
    student.full_name
  end

  # typusでpositionカラムを呼び出すとおかしな表示になるため。
  def decorate_position
    position
  end

  # typusで必要となるため
  def notebook_url
  end
end
