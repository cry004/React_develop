object false

classroom = @current_student.classroom

node(:student) do
  {
    id:             @current_student.id,
    avatar:         @current_student.avatar,
    nick_name:      @current_student.nick_name,
    full_name:      @current_student.full_name,
    school_year:    @current_student.schoolyear,
    school_address: @current_student.school_prefecture,
    level:          @current_student.level,
    trophies_count: @current_student.trophies_count,
    classroom_name: classroom&.name,
    classroom_type: classroom&.classroom_type
  }
end

node(:ranking_month) { @ranking_month }

node(:learning_time) do
  time = (@rank&.viewed_time.to_i / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:current_student_rankings) { @student_ranking }
node(:ranking_changes)          { @ranking_changes }

node(:rankings) { partial('v5/rankings/personal/_collection', object: @rankings) }
