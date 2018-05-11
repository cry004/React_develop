object false

node(:unit_id)    { @object.id }
node(:unit_name)  { @object.name }
node(:sub_units)  { partial('/shared/sub_units/_collection', object: @sub_units&.where(unit: @object))}
