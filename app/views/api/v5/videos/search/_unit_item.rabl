extend VideoHelper
object false

subject = Subject.find(@object[:subject_id])
node(:name) do
  {
    school_name:          I18n.t("school.#{subject.school}"),
    subject_name:         I18n.t("subject_name.#{subject.school}.#{subject.name}"),
    subject_key:          subject_key_by_subject_name(subject.name),
    subject_type:         video_type(subject),
    subject_detail_name:  video_detail_name(@object[:schoolyear], subject)
  }
end
node(:schoolbook_id)      { @object[:schoolbook_id] }
node(:title)              { @object['title'] }
node(:title_description)  { @object['title_description'] }
node(:completed)          { progress_for_units(@object, @videos_watched_ids) }
