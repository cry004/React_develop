object false
node(:video_id)       { @object.id }
node(:watched_count)  { @object.video_viewings_with_current_student.size }
node(:subname)        { @object.subtitle }
extends 'v5/videos/shared/_item', locals: { object: @object }
