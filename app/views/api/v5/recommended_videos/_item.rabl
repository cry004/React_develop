object false

subject = @object.subject

node(:video_id)        { @object.id }
node(:subname)         { @object.subtitle }
node(:subject)         { partial 'v5/shared/_subject', object: subject }
node(:video_type)      { @object.recommend_type }
node(:watched_count)   { @object.count_of_viewed}
extends 'v5/videos/shared/_item', locals: { object: @object }
