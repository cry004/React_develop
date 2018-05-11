object false

node(:total)           { @learnings.size }
node(:learnings) do
  object = if grouped_learnings.size == 1
             [grouped_learnings]
           else
             grouped_learnings
          end
  partial('/v5/boxes/_collection', object: object)
end

def grouped_learnings
  @learnings.group_by do |learning|
    {
      date:      learning.sent_on,
      period_id: learning.period_id
    }
  end
end
