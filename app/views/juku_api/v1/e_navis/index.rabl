object false

node(:reviews)    { partial('/e_navis/_collection', object: @object[:reviews] || [])    }
node(:challenges) { partial('/e_navis/_collection', object: @object[:challenges] || []) }
