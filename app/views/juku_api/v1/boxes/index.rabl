object false

node(:periods) { @boxes[:periods] }
node(:items)   { partial('/boxes/items/_collection', object: @boxes[:items]) }
