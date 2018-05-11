object false

node(:learnings_count)        { learnings.size }
node(:learned_count)          { learned_count }
node(:first_learning_title)   { @object.first&.sub_unit&.name || '' }
node(:last_learning_title)    { @object.last&.sub_unit&.name || '' }
node(:sub_subject_key)        { sub_subject[:key] || '' }
node(:sub_subject_name)       { sub_subject[:name] || '' }
node(:sub_subject_color_code) { sub_subject[:color] || '' }
node(:units) do
  partial('/learning_reports/_unit_collection', object: units)
end

def units
  Array(@object.sort_by { |learning| learning.sub_unit.unit.sort }
               .group_by { |learning| learning.sub_unit.unit })
end

def sub_subject
  return { key: '', name: '', color: '' } if @object.empty?
  schoolyear = unit.schoolyear
  subject    = unit.subject
  school     = subject.school
  name       = subject.name
  key = if schoolyear.in?(%w(c1 c2 c3))
          "#{schoolyear}_#{name}_regular"
        elsif subject.high_school_exam?
          subject.name_and_type
        else
          name
        end
  { key:   key,
    color: Subject::V3::COLOR_CODE[school][name],
    name:  I18n.t("sub_subject.#{school}.#{key}") }
end

def unit
  @object.first.sub_unit.unit
end

def learnings
  units = ::Unit.where(subject: unit.subject, schoolyear: unit.schoolyear)
  ::SubUnit.includes(:learnings).where(unit: units)
end

def learned_count
  learnings.where(learnings: { status:     %i(pass failure),
                               student_id: @object.first.student_id })
           .pluck(:sub_unit_id)
           .uniq.size
end
