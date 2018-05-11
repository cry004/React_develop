object false

def filled_agreements
  dows  = %w(02 03 04 05 06 07 01) # 月火水木金土日
  items = @object[:agreements]

  dows.map do |dow|
    items.find { |item| item[:day_of_the_week] == dow }
  end
end

node(:period_id)  { @object[:period_id] }
node(:agreements) do
  partial('students/_agreement_collection', object: filled_agreements)
end
