object false

node(:teacher_name) { @recommendation.teacher.honorific_name }
node(:date)         { @recommendation.created_at.to_s(:published_on_with_dow) }
node(:message)      { @recommendation.message }
node(:recommended_videos) do
  partial('v5/recommended_videos/_collection', object: @recommended_videos)
end
