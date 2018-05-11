object false

node(:box_id)             { @object[0][:box_id]           }
node(:agreement_id)       { @object[0][:agreement_id]     }
node(:date)               { @object[0][:date]             }
node(:period_id)          { @object[0][:period][:str_period_id] }
node(:period_start_time)  { I18n.l(@object[0][:period][:start_time], format: :api) }
node(:period_end_time)    { I18n.l(@object[0][:period][:end_time],   format: :api) }
node(:reported_at)        { I18n.l(@object[0][:reported_at]) }
node(:entrance_exam_flag) { units.flatten.first.subject.high_school_exam? }

node(:items) { partial('/learnings/histories/_unit_collection', object: units) }

def units
  Array(@object[1].group_by { |learning| learning.sub_unit.unit })
end
