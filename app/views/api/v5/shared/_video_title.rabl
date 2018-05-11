extend VideoHelper
object false

subject    = @object.subject
schoolyear = case @object
             when Schoolbook then @object.year
             when Video      then @object.schoolyear
             end
node(:school_name)         { I18n.t("school.#{subject.school}")}
node(:subject_key)         { subject_key_by_subject_name(subject.name) }
node(:subject_name)        { I18n.t("subject_name.#{subject.school}.#{subject.name}") }
node(:subject_type)        { video_type(subject) }
node(:subject_detail_name) { video_detail_name(schoolyear, subject) }
