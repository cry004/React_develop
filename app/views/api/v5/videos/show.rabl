extend VideoHelper

object @video

attributes :id

node(:subname)                    { @video.subtitle }
node(:chapters)                   { @video.chapters }
node(:video_url)                  { @video_url }
node(:lessontext_url)             { @video.lesson_text_image_url }
node(:lessontext_answer_url)      { @video.lesson_text_answer_image_url }

node(:lessontext_pdf_url)         { @video.lesson_text_url }
node(:lessontext_answer_pdf_url)  { @video.lesson_text_answer_url }
node(:subject)                    { partial('v5/shared/_subject', object: @video.subject) }

node(:double_speed_video_url)         { @double_speed_video_url }
node(:current_student_watched_count)  { @current_student_watched_count }
node(:total_watched_count)            { @video.view_count }
node(:is_bookmarked)                  { @is_bookmarked }
node(:locked_video)                   { locked_video?(@current_student, @belong_schoolbook, @video) }
node(:previous_videos)                { partial('v5/videos/_video_collection', object: @previous_videos) }
node(:next_videos)                    { partial('v5/videos/_video_collection', object: @next_videos) }

node(:kaisetu_web_url)                { @video.kaisetu_web_url }

extends 'v5/videos/shared/_item', locals: { object: @video }
