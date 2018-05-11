object false

node(:id)       { @question.id }
node(:state)    { partial('v5/questions/_state', object: @object) }
node(:unread)   { @question.unread_posts? }
node(:title)    { @first_post_body&.truncate(100) }
node(:body)     { @first_post_body }
node(:date)     { @question.created_at.to_s(:published_on) }
node(:video_id) { @question.video_id }
node(:position) { @question.position }
node(:type)     { @question.type }
node(:subject)  { partial('v5/shared/_subject', object: @question.subject) }
node(:image)    { partial('v5/shared/_image', object: @photo) }
