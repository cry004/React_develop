object false
video = @object.video
node(:video_id)       { video.id }
node(:watched_count)  { video.video_viewings_with_current_student.size }
node(:bookmarked_on)  { @object.created_at.to_s(:search_param_with_slash) }
extends 'v5/videos/shared/_item', locals: { object: video }
