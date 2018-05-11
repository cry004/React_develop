object false

node(:units_count)  { @units_count }
node(:units)        { partial 'v5/videos/search/_unit_collection', object: @units}
node(:videos_count) { @videos_count }
node(:videos)       { partial 'v5/videos/search/_video_collection', object: @videos }
