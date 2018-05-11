object false

node(:box_id)       { @box_id }
node(:student)      { partial('/shared/_student',                 object: @student) }
node(:agreement)    { partial('/shared/_agreement',               object: @agreement) }
node(:sub_subjects) { partial('/shared/sub_subjects/_collection', object: @sub_subjects) }
node(:curriculum)   { partial('/shared/curriculums/_collection',  object: @curriculum) }
node(:learnings)    { partial('/shared/_learning',                object: @units) }
