# == Schema Information
#
# Table name: units
#
#  id          :integer          not null, primary key
#  subject_id  :integer
#  name        :string
#  sort        :integer
#  schoolyear  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  unit_number :integer          default(0), not null
#
# Indexes
#
#  index_units_on_subject_id  (subject_id)
#


class Unit < ActiveRecord::Base
  belongs_to :subject
  has_many :sub_units, dependent: :destroy

  scope :learning_order, -> { order('units.sort', 'sub_units.sort') }
  scope :without_others, -> { where.not('units.schoolyear LIKE ?', '%_other') }
  scope :search_by_sub_subject, lambda { |subject, sub_subject|
    case sub_subject
    when /^(c.)_.+_regular$/
      where(subject: subject.children, schoolyear: Regexp.last_match(1))
    when /^(sociology|japanese)_(.+(standard|high-level))/
      joins(:subject).where(subject:  subject.children,
                            subjects: { type: Regexp.last_match(2) })
    when /^.+(standard|high-level)/
      joins(:subject).where(subject:  subject.children,
                            subjects: { type: Regexp.last_match(1) })
    else
      joins(:subject).where(subjects: { school: subject.school,
                                        name:   sub_subject,
                                        type:   :daily_report })
    end
  }
end
