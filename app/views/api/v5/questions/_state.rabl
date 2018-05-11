object @object
node(:key)  { @object.state_name_for_app }
node(:name) { I18n.t("question.state_name.#{@object.state_name_for_app}") }
