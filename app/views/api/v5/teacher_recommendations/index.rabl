object false

node(:recommendations) do
  partial('v5/teacher_recommendations/_collection', object: @recommendations)
end
