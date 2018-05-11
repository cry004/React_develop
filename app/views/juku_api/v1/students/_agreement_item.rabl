object false

node(:agreement_id)       { @object[:agreement_id] }
node(:agreement_dow)      { @object[:day_of_the_week] }
node(:agreement_dow_name) { dow_name }
node(:classroom_id)       { @object[:TMP_CD] }
node(:subjects) do
  partial('/students/_subject_collection', object: subjects)
end

def subjects
 ::Subject.where(id: @object[:subject_ids])
end

def dow_name
  dows = I18n.t('date.abbr_day_names')
  wday = @object[:day_of_the_week].to_i.pred
  "#{dows[wday]}曜"
end
