extend VideoHelper
object false

node(:title) do
  {
    school_name:          I18n.t("school.#{@object[:subject].school}"),
    subject_name:         I18n.t("subject_name.#{@object[:subject].school}.#{@object[:subject].name}"),
    subject_key:          subject_key_by_subject_name(@object[:subject].name),
    subject_type:         video_type(@object[:subject]),
    subject_detail_name:  video_detail_name(@object[:schoolyear], @object[:subject])
  }
end
node(:subject_key)     { @object[:subject].name_and_type }
node(:schoolyear)      { @object[:schoolyear] }
node(:trophies_progress)  { @object[:trophies_progress] }
node(:videos_progress) { @object[:videos_progress] }
