extend VideoHelper
object false
watched_count = @object.video_viewings_with_current_student.size
node(:video_id)       { @object.id }
node(:subname)        { @object.subtitle }
node(:watched)        { watched_count > 0 }
node(:locked_video)   { locked_video?(@current_student, @schoolbook, @object) }
node(:watched_count)  { watched_count }
extends 'v5/videos/shared/_item', locals: { object: @object }
