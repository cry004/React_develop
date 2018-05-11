extend SubjectHelper

object false

node(:id)         { @object.id }
node(:name)       { @object.name }
node(:name_short) { name_short_node(@object.name) }
node(:name_html)  { name_html_node(name: @object.name) }
node(:schoolyear) do
  { key:  @object.schoolyear,
    name: I18n.t("schoolyear_name.#{@object.schoolyear}") }
end
node(:url)   { @object.url }
node(:image) { partial 'v5/shared/_image', object: @object.product_photo }
