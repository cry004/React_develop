extend SubjectHelper
object false

node(:curriculum_id)      { @object.id }
node(:start_date)         { @object.start_date }
node(:end_date)           { @object.end_date }
node(:scheduled_count)    { @object.total_count }
node(:learned_count)      { @object.done_count }
