object false

node(:videos) do
  partial('v5/videos/bookmarks/_collection', object: @bookmarks)
end
