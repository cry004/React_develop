object false

student = @object.ranker
classroom = student.classroom

node(:student) do
  {
    id:             student.id,
    avatar:         student.avatar,
    nick_name:      student.nick_name,
    school_year:    student.schoolyear,
    school_address: student.school_prefecture,
    level:          student.level,
    trophies_count: student.trophies_count,
    classroom_name: classroom&.name,
    classroom_type: classroom&.classroom_type
  }
end

node(:learning_time)  do
  time = (@object.viewed_time / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:ranking_changes) do
  { prefecture: @object.prefecture_rank_variation,
    national:   @object.national_rank_variation,
    classroom:  @object.classroom_rank_variation }
end

node(:student_rankings) do
  { prefecture: @object.prefecture_rank,
    national:   @object.national_rank,
    classroom:  @object.classroom_rank }
end
