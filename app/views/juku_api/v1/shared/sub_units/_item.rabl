object false

is_curriculums      = @request.path_info.match(/\/v1\/students\/\d+\/curriculums/)
is_learning_reports = @request.path_info.match(/\/v1\/boxes\/\d+\/learning_reports/)
is_learnings        = @request.path_info.match(/\/v1\/students\/\d+\/learnings/)

if is_curriculums
  videos             = @object.videos.to_a.uniq(&:filename)
  total_duration     = @exam_flag ? videos.size * 30.minutes : videos.map(&:duration).sum
  learning           = @learnings.select { |learning| learning.sub_unit_id == @object.id }.sort_by{|e| e[:created_at]}.last
elsif is_learning_reports
  learning           = @object.learnings.where(student: @student).order('created_at').last
elsif is_learnings
  videos             = @object.videos.order(:filename).to_a.uniq(&:filename)
  total_duration     = @exam_flag ? videos.size * 30.minutes : videos.map(&:duration).sum
  learning           = @object.learnings.where(student: @student).order('created_at').last
end

node(:sub_unit_id)       { @object.id }
node(:sub_unit_name)     { @object.name }
node(:sub_unit_goals)    { videos.map(&:description).uniq }

unless is_learning_reports
  node(:total_duration)  { total_duration }
  node(:videos)          { partial('/shared/videos/_collection', object: videos) }
end

node(:learning_id)       { learning&.id }
node(:agreement_id)      { learning&.agreement_id }
node(:box_id)            { learning&.box_id }
node(:learning_status)   { learning&.status }
node(:curriculum_flag)   { learning.present? && learning.curriculum.present? }
node(:sent_on)           { learning&.sent_on }

reported_at = learning&.reported_at && I18n.l(learning&.reported_at)
if is_curriculums
  node(:learned_at)      { reported_at }
else
  node(:reported_at)     { reported_at }
end
