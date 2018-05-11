object false

node(:sub_unit_id)     { sub_unit.id }
node(:sub_unit_name)   { sub_unit.name }
node(:sub_unit_goals)  { videos.map(&:description).uniq }
node(:box_id)          { @object.box_id }
node(:learning_id)     { @object.id }
node(:agreement_id)    { @object.agreement_id }
node(:learning_status) { @object.status }
node(:curriculum_flag) { @object.curriculum.present? }
node(:sent_on)         { @object.sent_on }
node(:reported_at)     { @object.reported_at && I18n.l(@object.reported_at) }
node(:videos)          { partial('/shared/videos/_collection', object: videos) }

def sub_unit
  @object.sub_unit
end

def videos
  sub_unit.videos.to_a.uniq(&:filename)
end
