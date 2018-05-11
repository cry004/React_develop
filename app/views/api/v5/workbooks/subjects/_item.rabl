object false

subject = @object[0]

node(:school_name)  { I18n.t("school.#{subject[:school]}") }
node(:subject_name) { I18n.t("subject_name.#{subject[:school]}.#{subject[:name]}") }
node(:workbooks)    { partial('v5/workbooks/workbooks/_collection', object: @object[1]) }
