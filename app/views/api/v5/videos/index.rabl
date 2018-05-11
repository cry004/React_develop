object false
node(:completed_trophies_count) { @trophies_progress[:completed_trophies_count] }
node(:total_trophies_count)     { @trophies_progress[:total_trophies_count] }
node(:completed_videos_count)   { @videos_progress[:completed_videos_count] }
node(:total_videos_count)       { @videos_progress[:total_videos_count]}
node(:schoolbook_name)          { @schoolbook.name }
node(:title)          { partial('v5/shared/_video_title', object: @schoolbook) }
node(:videos_suggest) { partial('v5/videos/videos_suggest/videos', object: @videos_suggest) }
node(:units)          { partial('v5/videos/units/_collection', object: @units) }
