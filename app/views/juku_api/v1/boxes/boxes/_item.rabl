object false

student  = Student.find_by!(sit_cd: @object[:SIT_CD])
subjects = Subject.where(id: @object[:subject_id])

node(:agreement_id)       { @object[:agreement_id] }
node(:box_id)             { @object[:box_id] }
node(:classroom_id)       { @object[:TMP_CD] }
node(:student_id)         { student.id }
node(:student_name)       { student.full_name }
node(:schoolyear_key)     { student.gknn_cd }
node(:schoolyear_name)    { student.schoolyear }
node(:subjects) do
  locals = { sent_subject_ids: sent_subject_ids }
  partial('/boxes/subjects/_collection', object: subjects, locals: locals)
end

def sent_subject_ids
  Learning.joins(sub_unit: { unit: :subject })
          .where(subjects: { ancestry: @object[:subject_id] })
          .where(box_id: @object[:box_id])
          .where.not(status: :scheduled)
          .pluck(:ancestry)
end
