object false

node(:id)     { @object.id }
node(:title)  { @object.title }
node(:date)   { @object.published_at.to_s(:published_on) }
node(:unread) { @object.unread }
