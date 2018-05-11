object false

case (type = @object.class.name.underscore)
when 'teacher_recommendation'
  date       = @object.created_at
  title      = "#{@object.teacher.honorific_name}からの映像授業が届きました。"
  teacher_id = @object.teacher.id
when 'news'
  date  = @object.published_at
  title = @object.title
end

node(:notification_id)   { @object.id }
node(:notification_type) { type }
node(:teacher_id)        { teacher_id }
node(:title)             { title }
node(:date)              { date.to_s(:published_on) }
node(:unread)            { @object.unread }
