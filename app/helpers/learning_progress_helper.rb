module LearningProgressHelper
  def ids_schoolbook(list)
    grade = @current_student.school
    subjects_has_schoolyear = []
    subjects_in_course = list[1]
    subjects_in_course.each do |subject|
      subject_name = subject[0]
      subject_videos = subject[1]
      next subjects_has_schoolyear << subject_videos[:id] if grade == 'k'
      if subject_name.start_with?('geography_', 'history_', 'civics_') || subject_name.end_with?('_standard', '_high-level')
        subjects_has_schoolyear << [subject_videos].flatten.first['id']
      else
        subjects_has_schoolyear += subject_videos.map { |schoolbook| schoolbook['id'] }
      end
    end
    subjects_has_schoolyear
  end

  def progress_with_list_schoolbooks(array_id_of_schoolbook, watched_videos)
    schoolbooks = Schoolbook.where(id: array_id_of_schoolbook)
    units = schoolbooks.pluck(:units).flatten
    watched_videos_id = watched_videos.pluck(:id)
    student_learning_progress(units, watched_videos_id)
  end

  def progress_with_a_schoolbook(schoolbook, watched_videos_id)
    units = schoolbook.units
    student_learning_progress(units, watched_videos_id)
  end

  def student_learning_progress(units, watched_videos_id)
    completed_videos_count   = total_videos_count   = 0
    completed_trophies_count = total_trophies_count = 0

    units.each do |unit|
      video_ids = unit['videos'].map{ |video| video['id'] }
      video_watched_ids = watched_videos_id & video_ids

      total_videos_count     += video_ids.size
      completed_videos_count += video_watched_ids.size
      total_trophies_count     = total_trophies_count.next
      completed_trophies_count = completed_trophies_count.next if video_ids.size == video_watched_ids.size
    end
    { total_videos_count:       total_videos_count,
      completed_videos_count:   completed_videos_count,
      total_trophies_count:     total_trophies_count,
      completed_trophies_count: completed_trophies_count }
  end

  def find_schoolbook_with_video(video, student = nil)
    student    = @current_student || student
    schoolyear = video.schoolyear == 'c' ? 'c1' : video.schoolyear
    schoolbook = Schoolbook.find_by!(id: student.get_schoolbook_id(schoolyear, video.subject_name))
    schoolbook.has_video?(video.id) ? schoolbook : Schoolbook.where(subject: video.subject).find { |sb| sb.video_ids.include? video.id }
  end

  def belonging_to_unit(schoolbook, video)
    schoolbook.units.find do |u|
      u['videos'].any? { |video_hash| video_hash['id'] == video.id }
    end
  end

  def get_unit_video_ids(unit)
    unit['videos'].map{ |vid| vid['id'] } if unit
  end
end
