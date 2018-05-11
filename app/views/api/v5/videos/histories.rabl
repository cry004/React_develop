object false

node(:videos) do
  partial('v5/videos/histories/_collection', object: @watching_history)
end
