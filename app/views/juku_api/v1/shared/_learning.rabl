object false

node(:learnings_count)      { sub_units.size }
node(:learned_count)        { learned_count }
node(:first_learning_title) { curriculum_sub_units&.first&.name if @curriculum }
node(:last_learning_title)  { curriculum_sub_units&.last&.name if @curriculum }
node(:todo_learning_ids)    { @todo_learning_ids }
node(:total_video_duration) { @sum_duration }
node(:entrance_exam_flag)   { @object.flatten.first.subject.high_school_exam? }
node(:units)                { partial('/shared/units/_collection', object: @object) }

def sub_units
  ::SubUnit.includes(:learnings).where(unit: @object.to_a)
end

def curriculum_sub_units
  ::SubUnit.includes(:unit, :learnings)
           .where(learnings: { curriculum: @curriculum })
           .order('units.schoolyear, units.sort, sub_units.sort')
end

def learned_count
  sub_units.where(learnings: { status:  %i(pass failure),
                               student: @student })
           .pluck(:sub_unit_id)
           .uniq.size
end
