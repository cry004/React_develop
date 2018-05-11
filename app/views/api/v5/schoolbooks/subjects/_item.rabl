SOCIAL_STUDIES = %w(geography history civics)
object false

node do
  {
    course_name:  @object[0].name.in?(SOCIAL_STUDIES) ? 'social_studies' : @object[0].name,
    key:  @object[0].name,
    name: I18n.t("subject_detail_name.#{@object[0].school}.#{@object[0].name}")
  }
end

node(:schoolbooks) do
  partial('v5/schoolbooks/schoolbooks/_collection', object: @object[1])
end
