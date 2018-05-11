object false

node(:periods)  { @periods }
node(:students) { partial('students/_collection', object: @students) }
