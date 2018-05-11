object false

node(:type) { @object.poster_type }
node(:name) { I18n.t("user.role.#{@object.poster_type}") }
node(:avatar) { @object.postable_id.present? ? @current_student.avatar : nil}
