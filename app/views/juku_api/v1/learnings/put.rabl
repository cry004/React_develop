object false

reported_at = @learning&.reported_at && I18n.l(@learning.reported_at)
period_id   = @learning&.period&.str_period_id

node(:learning_id)          { @learning&.id }
node(:agreement_id)         { @learning&.agreement_id }
node(:student_id)           { @learning&.student_id }
node(:sub_unit_id)          { @learning&.sub_unit_id }
node(:curriculum_id)        { @learning&.curriculum_id }
node(:box_id)               { @learning&.box_id }
node(:learning_status)      { @learning&.status }
node(:sent_on)              { @learning&.sent_on }
node(:reported_at)          { reported_at }
node(:period_id)            { period_id }
node(:total_video_duration) { @sum_duration }
