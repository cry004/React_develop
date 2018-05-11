object false

node(:subjects)  { partial('/shared/subjects/_collection',     object: @subjects) }
node(:learnings) { partial('/learnings/histories/_collection', object: @learnings) }
