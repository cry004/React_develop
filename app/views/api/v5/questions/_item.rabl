object @object

attributes :id, :position, :video_id, :created_at

content = @object.first_post_body

node(:state)      { partial('v5/questions/_state', object: @object) }
node(:unread)     { @object.unread_posts? }
node(:date)       { @object.created_at.to_s(:published_on_with_dow) }
node(:subject)    { partial('v5/shared/_subject', object: @object.subject) }
node(:title)      { content&.truncate(100) }
node(:content)    { content }
node(:type)       { @object.build_type_node }
node(:resolvable) { @object.can_close? }
node(:duration) do
  {
    seconds: @object.position,
    text:    Duration.new(seconds: @object.position).format('%M:%S')
  } if @object.video
end
node(:image) do
  photo = @object.posts.where(postable_type: 'Student').first&.photo
  partial('v5/shared/_image', object: photo, locals: { thumbnail_flag: true })
end
