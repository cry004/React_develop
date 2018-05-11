extend VideoHelper
object @object
node(:key) { subject_key_by_subject_name(@object.name) }
node(:name) do
  @object.school ? I18n.t("subject_name.#{@object.school}.#{@object.name}") : I18n.t("courses_name.#{@object.name}")
end
