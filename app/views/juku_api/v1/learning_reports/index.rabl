object false

node(:box_id)       { @box_id }
node(:report_date)  { @report_date }
node(:student)      { partial('/shared/_student',                         object: @student) }
node(:agreement)    { partial('/shared/_agreement',                       object: @agreement) }
node(:curriculums)  { partial('/learning_reports/_curriculum_collection', object: @reports) }
node(:e_navis)      { partial('/e_navis/index',                           object: @e_navis.presence || { reviews: [], challenges: [] }) }
