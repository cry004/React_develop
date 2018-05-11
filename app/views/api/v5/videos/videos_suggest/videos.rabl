object false
node(:type)   { @object[:type] }
node(:videos) { partial('v5/videos/videos_suggest/_collection', object: @object[:videos]) }
