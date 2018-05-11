object false

def student
  ::Student.find_by!(sit_cd: @object[:SIT_CD])
end

def filled_periods
  items = @object[:periods].select { |item| item[:period_id] }

  period_ids = @periods.map { |period| period[:id] }
  item_ids   = items.map { |period| period[:period_id] }
  diff_ids   = period_ids - item_ids

  diff_ids.each do |id|
    items << { period_id: id, agreements: [] }
  end

  items.sort_by { |item| item[:period_id] }
end

node(:student_id)        { student.id }
node(:student_name)      { student.full_name }
node(:student_name_kana) { student.full_name_kana }
node(:schoolyear_key)    { student.gknn_cd }
node(:schoolyear_name)   { student.schoolyear }
node(:periods) do
  partial('students/_period_collection', object: filled_periods)
end
