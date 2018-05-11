object false

dows     = I18n.t('date.abbr_day_names')
wday     = @object[:day_of_the_week].to_i.pred
dow_name = "#{dows[wday]}曜"

node(:agreement_id)       { @object[:agreement_id] }
node(:subject_id)         { @subject.id }
node(:subject_name)       { @subject.description }
node(:subject_color_code) { ::Subject::V3::COLOR_CODE[@subject.school][@subject.name] }
node(:agreement_dow)      { @object[:day_of_the_week] }
node(:agreement_dow_name) { dow_name }
node(:period_id)          { @object[:period_id] }
node(:start_time)         { @object[:start_time] }
node(:end_time)           { @object[:end_time] }
