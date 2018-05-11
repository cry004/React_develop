object false
video = @object.video
node(:history_id)     { @object.id }
node(:video_id)       { video.id }
node(:watched_count)  { @videos_list[@object] }
node(:watched_on)     { @object.created_at.to_s(:search_param_with_slash) }
node(:is_bookmarked)  { video.stars_with_current_student.present? }
extends 'v5/videos/shared/_item', locals: { object: video }
