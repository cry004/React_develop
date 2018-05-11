# == Schema Information
#
# Table name: learning_reports
#
#  id              :integer          not null, primary key
#  student_id      :integer          not null
#  agreement_id    :string           not null
#  agreement_dow   :string
#  start_date      :date
#  end_date        :date
#  total_count     :integer          default(0), not null
#  done_count      :integer          default(0), not null
#  period_id       :integer          not null
#  sub_subject_key :string           not null
#  curriculum_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reported_at     :datetime         not null
#
# Indexes
#
#  index_learning_reports_on_curriculum_id  (curriculum_id)
#  index_learning_reports_on_period_id      (period_id)
#  index_learning_reports_on_student_id     (student_id)
#
# Foreign Keys
#
#  fk_rails_38ab64660a  (curriculum_id => curriculums.id)
#  fk_rails_4359ec88f0  (period_id => periods.id)
#  fk_rails_d449bd9382  (student_id => students.id)
#

class LearningReport < ActiveRecord::Base
  belongs_to :curriculum
  belongs_to :period
  belongs_to :student
  has_many :learnings

  validates :agreement_dow, inclusion: %w(01 02 03 04 05 06 07), # 日月火水木金土
                            allow_nil: true

  class << self
    def build_reports!(learnings, agreement_id)
      grouped_learnings = learnings.group_by(&:curriculum_id)

      learnings.each do |l|
        siblings   = grouped_learnings[l.curriculum_id]
        done_count = siblings.size - siblings.count(&:resended?)

        l.learning_report = find_or_create_by!(
          student:         l.student,
          agreement_id:    agreement_id,
          agreement_dow:   l.curriculum&.agreement_dow,
          start_date:      l.curriculum&.start_date,
          end_date:        l.curriculum&.end_date,
          total_count:     l.curriculum&.total_count.to_i,
          done_count:      l.curriculum&.done_count.to_i + done_count,
          period_id:       l.period_id,
          sub_subject_key: get_subsubject(l.sub_unit.unit),
          curriculum:      l.curriculum,
          reported_at:     l.reported_at
        )
      end
    end

    private

    def get_subsubject(unit)
      subject      = unit.subject
      school       = subject.school
      subject_name = subject.name

      if subject.high_school_exam?
        subject.name_and_type
      elsif school == 'c' && subject_name.in?(%w(english mathematics science))
        "#{unit.schoolyear}_#{subject_name}_regular"
      else
        subject.name
      end
    end
  end
end
