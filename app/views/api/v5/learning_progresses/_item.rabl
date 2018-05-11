extend LearningProgressHelper
object false
node(:subject_name) do
  { key: @object[0],
    name: I18n.t("subject_name.#{@school}.#{@object[0]}") }
end

array_id_of_schoolbook = ids_schoolbook(@object)
progress = progress_with_list_schoolbooks(array_id_of_schoolbook, @watched_videos)
node(:total_videos_count)       { progress[:total_videos_count] }
node(:watched_videos_count)     { progress[:completed_videos_count] }
node(:total_trophies_count)     { progress[:total_trophies_count] }
node(:completed_trophies_count) { progress[:completed_trophies_count] }
