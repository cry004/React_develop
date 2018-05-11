object false

node(:student)   { partial('/shared/_student',                 object: @student) }
node(:learnings) { partial('/learnings/learnings/_collection', object: @units) }
