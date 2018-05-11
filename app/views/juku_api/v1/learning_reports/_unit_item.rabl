object false

unit = Array(@object)[0]

node(:unit_id)   { unit.id }
node(:unit_name) { unit.name }
node(:sub_units) do
  partial('/learning_reports/_learning_collection',
          object: @object[1].sort_by { |learning| learning.sub_unit.sort })
end
