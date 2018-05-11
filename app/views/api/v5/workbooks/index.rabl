object false
node(:subjects) do
  partial('v5/workbooks/subjects/_collection', object: Array(@workbooks))
end
