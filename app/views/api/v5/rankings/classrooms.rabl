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

node(:ranking_date) do
  start_date = @ranking_classroom&.aggregation_start_date
  end_date   = @ranking_classroom&.aggregation_end_date
  { start: start_date && I18n.l(start_date),
    end:   end_date   && I18n.l(end_date) }
end

node(:ranking_month) { @ranking_month }

node(:learning_time) do
  time = (@rank&.viewed_time.to_i / 60).divmod(60)
  { hours:   time[0],
    minutes: time[1] }
end

node(:current_classroom_rankings) do
  { prefecture: @rank&.prefecture_rank,
    national:   @rank&.national_rank }
end

node(:ranking_changes) do
  { prefecture: @rank&.prefecture_rank_variation,
    national:   @rank&.national_rank_variation }
end

node(:rankings) do
  { classroom_prefecture: (partial 'v5/rankings/classroom/_collection', object: @prefecture_classroom_ranks),
    classroom_national:   (partial 'v5/rankings/classroom/_collection', object: @national_classroom_ranks),
    schoolhouse_national: (partial 'v5/rankings/classroom/_collection', object: @national_schoolhouse_ranks) }
end
