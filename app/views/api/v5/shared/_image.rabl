object false

resource_url, height, width =
  if @thumbnail_flag && @object.is_a?(QuestionPhoto) && @object.image_thumbnail
    thumbnail = @object.image_thumbnail
    [thumbnail.remote_url, thumbnail.height, thumbnail.width]
  else
    [@object.resource_url, @object.height, @object.width]
  end

common = { resource_url: resource_url,
           height:       height,
           width:        width,
           height_ratio: @object.height_ratio || 1.0 }

node(:mobile)  { common }
node(:desktop) { common }
