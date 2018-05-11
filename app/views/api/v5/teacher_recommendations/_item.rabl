object false
node(:recommendation_id)        { @object.id }
node(:teacher_name)             { @object.teacher.honorific_name }
node(:date)                     { @object.created_at.to_s(:search_param_with_slash) }
node(:message)                  { @object.message }
node(:unread)                   { @object.unread }
