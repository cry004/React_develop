object false

sub_unit = @object.sub_unit

node(:sub_unit_id)     { sub_unit.id }
node(:sub_unit_name)   { sub_unit.name }
node(:sub_unit_goals)  { sub_unit.videos.map(&:description).uniq }
node(:total_duration)  { sub_unit.videos.sum_duration }
node(:videos)          { partial('/shared/videos/_collection', object: sub_unit.videos) }
node(:learning_id)     { @object.id }
node(:agreement_id)    { @object.agreement_id }
node(:learning_status) { @object.status }
node(:curriculum_flag) { @object.curriculum.present? }
node(:sent_on)         { @object.sent_on }
node(:reported_at)     { @object.reported_at && I18n.l(@object.reported_at) }
