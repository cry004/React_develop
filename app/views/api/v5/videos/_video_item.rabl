extend VideoHelper
object false

node(:id)                            { @object.id }
node(:chapters)                      { @object.chapters }
node(:subname)                       { @object.subtitle }
node(:locked_video)                  { locked_video?(@current_student, @belong_schoolbook, @object) }
node(:current_student_watched_count) { @object.video_viewings_with_current_student.size }
extends 'v5/videos/shared/_item', locals: { object: @object }
