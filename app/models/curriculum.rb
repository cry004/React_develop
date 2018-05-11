# == Schema Information
#
# Table name: curriculums
#
#  id              :integer          not null, primary key
#  student_id      :integer          not null
#  agreement_id    :string           not null
#  agreement_dow   :string           not null
#  start_date      :date
#  end_date        :date
#  total_count     :integer          default(0), not null
#  done_count      :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  period_id       :integer          not null
#  sub_subject_key :string           not null
#
# Indexes
#
#  index_curriculums_on_period_id   (period_id)
#  index_curriculums_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_4c04e9f77d  (student_id => students.id)
#  fk_rails_d769ab9fc4  (period_id => periods.id)
#

class Curriculum < ActiveRecord::Base
  belongs_to :period
  belongs_to :student
  has_many :learning_reports
  has_many :learnings

  validates :agreement_dow, inclusion: %w(01 02 03 04 05 06 07) # 日月火水木金土

  # カリキュラムに設定された授業を紐付ける
  def build_learnings(sub_unit_ids: [])
    sub_unit_ids.each do |sub_unit_id|
      exist = ::Learning.where(student: student, sub_unit_id: sub_unit_id)
                        .order('created_at DESC')
                        .first

      next if exist && (exist.update(curriculum: self))

      learnings.build(student:      student,
                      sub_unit_id:  sub_unit_id,
                      period_id:    period_id,
                      agreement_id: agreement_id)
    end
  end

  # カリキュラムに設定された授業の紐付けを更新する
  def build_and_release_learnings!(sub_unit_ids: [])
    exist_ids   = learnings.pluck(:sub_unit_id)
    release_ids = exist_ids - sub_unit_ids
    build_ids   = sub_unit_ids - exist_ids

    releases = learnings.where(sub_unit_id: release_ids)
    releases.where(status: :scheduled).find_each(&:destroy!)
    releases.find_each { |release| release.update!(curriculum: nil) }

    build_learnings(sub_unit_ids: build_ids)
  end
end
