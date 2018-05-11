object false

classroom = @object.ranker

node(:classroom) do
  {
    id:              classroom.id,
    color:           classroom.color_number,
    name:            classroom.name,
    type:            classroom.classroom_type,
    prefecture_name: classroom.prefecture_name
  }
end

node(:learning_time)  do
  time = (@object.viewed_time / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:ranking_changes) do
  { prefecture: @object.prefecture_rank_variation,
    national:   @object.national_rank_variation }
end

node(:classroom_rankings) do
  { prefecture: @object.prefecture_rank,
    national:   @object.national_rank }
end
