object false

node(:questions) do
  partial('v5/questions/_collection', object: @question_pagination)
end
