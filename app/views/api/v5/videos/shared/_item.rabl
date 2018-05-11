object false

node(:duration) do
  {
    seconds: @object.duration,
    text:    Duration.new(seconds: @object.duration).format('%M:%S')
  }
end
node(:title)          { partial('v5/shared/_video_title', object: @object) }
node(:name)           { @object.name }
node(:name_html)      { @object.name.gsub(/(π|√)/, '<span class="mark">\\1</span>') }
node(:thumbnail_url)  { @object.thumbnail_url }
