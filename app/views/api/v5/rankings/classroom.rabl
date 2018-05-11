object false

node(:classroom) do
  {
    id:              @classroom&.id,
    color:           @classroom&.color_number,
    name:            @classroom&.name,
    type:            @classroom&.classroom_type,
    prefecture_name: @classroom&.prefecture_name
  }
end

node(:ranking_month) { @ranking_month }

node(:learning_time) do
  time = (@rank&.viewed_time.to_i / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:current_classroom_rankings) { @classroom_ranking }
node(:ranking_changes)            { @ranking_changes }

node(:rankings) { partial('v5/rankings/classroom/_collection', object: @rankings) }
