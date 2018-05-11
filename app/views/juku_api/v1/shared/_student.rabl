object false

node(:student_id)   { @object.id }
node(:student_name) { @object.full_name }
node(:avatar_url)   { ::StudentAvatar.get_url_for_learning(@object) }
node(:schoolyear)   { @object.schoolyear }
