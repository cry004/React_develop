object false

unit = Array(@object)[0]

node(:sub_subject_key)        { sub_subject(unit)[:key] }
node(:sub_subject_name)       { sub_subject(unit)[:name] }
node(:sub_subject_color_code) { sub_subject(unit)[:color] }
node(:unit_id)                { unit.id }
node(:unit_name)              { unit.name }
node(:sub_units)              { partial('/learnings/histories/_learning_collection', object: @object[1]) }

def sub_subject(unit)
  schoolyear = unit.schoolyear
  subject    = unit.subject
  school     = subject.school
  name       = subject.name
  key = if schoolyear.in?(%w(c1 c2 c3))
          "#{schoolyear}_#{name}_regular"
        elsif subject.high_school_exam? || subject.university_exam?
          subject.name_and_type
        else
          name
        end
  { key:   key,
    color: Subject::V3::COLOR_CODE[school][name],
    name:  I18n.t("sub_subject.#{school}.#{key}") }
end
