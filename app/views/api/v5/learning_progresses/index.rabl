object false

node(:student) do
  {
    id:             @current_student.id,
    avatar:         @current_student.avatar,
    nick_name:      @current_student.nick_name,
    full_name:      @current_student.full_name,
    school_year:    @current_student.schoolyear,
    school_address: @current_student.school_prefecture,
    school:         @school,
    level:          @current_student.level,
    classroom_name: @current_student.classroom&.name
  }
end

node(:level_progress)                  { @current_student.level_progress }
node(:experience_point_for_next_level) { @current_student.experience_point_for_next_level }
node(:learning_time) do
  { hours:   learning_time[0],
    minutes: learning_time[1] }
end
node(:watched_videos_count) { @watched_videos.size }
node(:completed_trophies_count) { @trophies_completed }
node(:subjects) { partial 'v5/learning_progresses/_collection', object: @subject_list }

node(:last_learning_subjects) { partial 'v5/learning_progresses/last_learning/_collection', object: @last_five_subject_watched }

def learning_time
  (@current_student.viewing_time / 60).divmod(60)
end
