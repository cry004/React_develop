object false

node(:key)      { @object[:schoolyear] }
node(:subjects) do
  partial('v5/schoolbooks/subjects/_collection', object: @object[:subject])
end
