object false

node(:curriculum_id)      { @object[:curriculum_id] }
node(:learning_report_id) { @object[:id] }
node(:start_date)         { @object[:start_date] }
node(:end_date)           { @object[:end_date] }
node(:scheduled_count)    { @object[:total_count] }
node(:learned_count)      { @object[:done_count] }
node(:learnings) do
  if curriculumed_learnings.blank?
    partial('/learning_reports/_collection', object: [curriculumed_learnings])
  else
    partial('/learning_reports/_item', object: curriculumed_learnings)
  end
end

def curriculumed_learnings
  @object.learnings
end
