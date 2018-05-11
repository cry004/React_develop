object @question

attributes :id, :created_at

node(:state)      { partial('v5/questions/_state', object: @question) }
node(:type)       { @question.build_type_node }
node(:unread)     { @question.unread_posts? }
node(:title)      { @question.first_post_body&.truncate(100) }
node(:resolvable) { @question.can_close? }
node(:subject)    { partial('v5/shared/_subject', object: @question.subject) }
node(:posts) do
  posts = @question.posts.displayable.includes(:photo)
  partial('v5/questions/posts/_collection', object: posts)
end
