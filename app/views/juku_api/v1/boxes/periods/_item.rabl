object false

node(:period_id) { @object[:period_id] }
node(:boxes)     { partial('/boxes/boxes/_collection', object: @object[:boxes]) }
