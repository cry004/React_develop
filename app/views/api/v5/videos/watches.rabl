object false

node(:level)                  { @current_level }
node(:level_up_flag)          { @level_up_flag }
node(:experience_point)       { @experience_point }
node(:unit_trophy_flag)       { @unit_trophy_flag }
node(:schoolbook_trophy_flag) { @schoolbook_trophy_flag }
node(:unit_name)              { @unit_name }
node(:trophies_progress)      { @trophies_progress }
node(:title) { partial('v5/shared/_video_title', object: @video_watched) }
