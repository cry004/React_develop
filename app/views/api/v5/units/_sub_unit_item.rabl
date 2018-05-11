object false

video = @video_records.detect { |record| record.id == @object['id'] }

node(:title)              { @object['title'] }
node(:video_id)           { @object['id'] }
node(:video_watched_flag) { @watched_video_ids.include?(@object['id']) }

node(:watched_count)      { video.video_viewings_with_current_student.size }
node(:subname)            { video.subtitle }

extends 'v5/videos/shared/_item', locals: { object: video }
