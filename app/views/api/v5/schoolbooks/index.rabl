object false
node(:schoolyears) do
  partial('v5/schoolbooks/schoolyears/_collection', object: @schoolbooks)
end
