object false

node(:id)           { @object.id }
node(:name)         { @object.name }
node(:company)      { @object.company }
node(:display_name) { @object.company.present? ? "#{@object.name}（#{@object.company}）" : @object.name }
node(:selected_flag) do
  year = @object.year
  key  = @object.subject.name_and_type
  @object.id == @setted_schoolbooks[year][key]['id']
end
