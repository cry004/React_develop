object false

node(:title)     { "#{@object['title']} #{@object['title_description']}" }
node(:completed) { @object['completed'] }
node(:videos)    { partial 'v5/videos/units/unit_videos/_collection', object: @object['videos'] }
