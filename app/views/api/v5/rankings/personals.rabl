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

node(:ranking_date) do
  start_date = @ranking&.aggregation_start_date
  end_date   = @ranking&.aggregation_end_date
  { start: start_date && I18n.l(start_date),
    end:   end_date   && I18n.l(end_date) }
end

node(:ranking_month) { @ranking_month }

node(:learning_time) do
  time = (@rank&.viewed_time.to_i / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:current_student_rankings) do
  { prefecture: @rank&.prefecture_rank,
    national:   @rank&.national_rank,
    classroom:  @rank&.classroom_rank }
end

node(:ranking_changes) do
  { prefecture: @rank&.prefecture_rank_variation,
    national:   @rank&.national_rank_variation,
    classroom:  @rank&.classroom_rank_variation }
end

node(:rankings) do
  { prefecture: (partial 'v5/rankings/personal/_collection', object: @prefecture_ranks),
    national:   (partial 'v5/rankings/personal/_collection', object: @national_ranks),
    classroom:  (partial 'v5/rankings/personal/_collection', object: @classroom_ranks) }
end
