object false

node(:subject_id)         { @object.id }
node(:subject_name)       { @object.description }
node(:subject_color_code) { Subject::V3::COLOR_CODE[@object.school][@object.name] }
node(:sent_flag)          { @object.id.to_s.in?(@sent_subject_ids) }
