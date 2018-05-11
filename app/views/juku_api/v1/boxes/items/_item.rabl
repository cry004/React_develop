object false

date = @object[:date]
flag = date ? UserStatic.instance.holiday?(date.to_date) : false

node(:date)         { date }
node(:holiday_flag) { flag }
node(:periods) do
  partial('/boxes/periods/_collection', object: filled_periods)
end

def filled_periods
  periods = @boxes[:periods]
  items   = @object[:periods].select { |item| item['period_id'] }

  period_ids = periods.map { |period| period[:id] }
  item_ids   = items.map { |period| period[:period_id] }
  diff_ids   = period_ids - item_ids

  diff_ids.each do |id|
    items << { period_id: id, boxes: [] }
  end

  items
end
