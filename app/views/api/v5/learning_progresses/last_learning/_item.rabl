extend LearningProgressHelper
object false
@object = @object.first
schoolbook = find_schoolbook_with_video(@object[1].first)
watched_videos_id = @object[1].map(&:id)
progress = progress_with_a_schoolbook(schoolbook, watched_videos_id)
extends 'v5/shared/_video_title', object: @object[1].first
node(:total_video_count)        { progress[:total_videos_count] }
node(:learned_video_count)      { progress[:completed_videos_count] }
node(:total_trophies_count)     { progress[:total_trophies_count] }
node(:completed_trophies_count) { progress[:completed_trophies_count] }
@object[0][0] = 'c1' if @object[0][0] == 'c'
node(:schoolyear)             { @object[0][0] }
node(:subject_name_and_type)  { Subject.find(@object[0][1]).name_and_type }
