extend VideoHelper
object false

node(:video_id)      { @object.id }
node(:subname)       { @object.subtitle }
node(:locked_video)  { locked_video?(@current_student, @schoolbook, @object) }
node(:watched_count) { @object.video_viewings_with_current_student.size }
extends 'v5/videos/shared/_item', locals: { object: @object }
