object false

node(:sub_subject_key)        { sub_subject[:key] }
node(:sub_subject_name)       { sub_subject[:name] }
node(:sub_subject_color_code) { sub_subject[:color] }
node(:unit_id)                { @object.id }
node(:unit_name)              { @object.name }
node(:sub_units)              { partial('/shared/sub_units/_collection', object: @object.sub_units) }

def sub_subject
  schoolyear = @object.schoolyear
  subject    = @object.subject
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
