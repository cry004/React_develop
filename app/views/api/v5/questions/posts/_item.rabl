object false

node(:id) { @object.id }
node(:date) { @object.created_at.to_s(:published_on_with_dow) }
node(:content) { @object.body }
node(:image) { partial('v5/shared/_image', object: @object.photo) }
node(:auto_reply) { @object.auto_reply }
node(:poster) { partial('v5/questions/posts/_poster', object: @object) }
