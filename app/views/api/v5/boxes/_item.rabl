object false

@object = @object.to_a[0] if @object.instance_of?(Hash)
box_info     = @object[0]
date         = box_info[:date]
period       = ::Period.find(box_info[:period_id])
start_time   = I18n.l(period.start_time, format: :api)
end_time     = I18n.l(period.end_time,   format: :api)
day_of_date  = I18n.l(date, format: '%a')

node(:date)         { date.to_datetime.to_s(:search_param_with_slash) }
node(:start_time)   { start_time }
node(:end_time)     { end_time }
node(:dow)          { day_of_date }

videos = []
@object[1].each do |learning|
  videos += learning.sub_unit.videos
end

node(:items) do
  partial('/v5/juku_learnings/video_learnings/collection', object: videos)
end
