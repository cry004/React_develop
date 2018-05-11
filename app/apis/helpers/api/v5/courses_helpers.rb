module API::V5::CoursesHelpers
  def find_course(course_name, grade)
    subject_keys            = Settings.courses[grade][course_name]
    subjects_has_schoolyear = add_schoolyear_to_subjects(subject_keys, grade)
    current_schoolbooks     = find_schoolbooks(subjects_has_schoolyear)
    watched_video_ids       = @current_student.videos.watched_videos.pluck(:id)
    current_schoolbooks.map do |current_schoolbook|
      subject_progress(current_schoolbook, watched_video_ids)
    end
  end

  def find_courses_progress(courses)
    trophies_progress = { completed_trophies_count: 0, total_trophies_count: 0 }
    videos_progress   = { completed_videos_count:   0,   total_videos_count: 0 }
    courses = courses.map { |course| course[:course] }
    courses.flatten(1).each do |course|
      trophies_progress_of_course = course[:trophies_progress]
      trophies_progress[:completed_trophies_count] += trophies_progress_of_course[:completed_trophies_count]
      trophies_progress[:total_trophies_count]     += trophies_progress_of_course[:total_trophies_count]

      videos_progress_of_course = course[:videos_progress]
      videos_progress[:completed_videos_count] += videos_progress_of_course[:completed_videos_count]
      videos_progress[:total_videos_count]     += videos_progress_of_course[:total_videos_count]
    end
    { trophies_progress: trophies_progress, videos_progress: videos_progress }
  end

  def find_schoolbook_name(courses)
    subject = courses.first[:course].first
    return nil unless subject
    Schoolbook.find_by!(id: @current_student.get_schoolbook_id(subject[:schoolyear], subject[:subject])).name
  end

  private

  def find_schoolbooks(subjects_has_schoolyear)
    schoolbook_ids = subjects_has_schoolyear.map do |subject_has_schoolyear|
      @current_student.get_schoolbook_id(subject_has_schoolyear[:schoolyear], subject_has_schoolyear[:subject])
    end
    Schoolbook.where(id: schoolbook_ids).includes(:subject).order('subjects.sort', :year)
  end

  def subject_progress(schoolbook, watched_video_ids)
    units_video_ids = filter_video_ids(schoolbook)
    schoolbook_progress       = get_schoolbook_progress(units_video_ids, watched_video_ids)

    { schoolyear: schoolbook.year,
      subject:    schoolbook.subject,
      trophies_progress: schoolbook_progress[:trophies_progress],
      videos_progress:   schoolbook_progress[:videos_progress] }
  end

  def filter_video_ids(schoolbook)
    schoolbook.units.map { |unit| unit['videos'].map{|video| video['id']}}
  end

  def get_schoolbook_progress(units_video_ids, watched_video_ids)
    completed_videos_count   = total_videos_count   = 0
    completed_trophies_count = total_trophies_count = 0
    units_video_ids.map do |unit_video_ids|
      videos_unit_completed = unit_video_ids & watched_video_ids

      completed_videos_count += videos_unit_completed.size
      total_videos_count     += unit_video_ids.size
      completed_trophies_count = completed_trophies_count.next if videos_unit_completed == unit_video_ids
      total_trophies_count     = total_trophies_count.next
    end
    videos_progress   = { completed_videos_count:   completed_videos_count,   total_videos_count:   total_videos_count }
    trophies_progress = { completed_trophies_count: completed_trophies_count, total_trophies_count: total_trophies_count }
    { videos_progress: videos_progress, trophies_progress: trophies_progress }
  end

  def find_current_video_with_schoolyear(videos, schoolyear, subject)
    schoolyear = 'c' if subject.end_with?('_standard', '_high-level')
    videos.find {|video| video.schoolyear == schoolyear}
  end

  def add_schoolyear_to_subjects(subject_keys, grade)
    subjects_for_current_grade = Settings.subject_name_and_type[grade]
    subjects = []
    subject_keys.each do |subject_key|
      subjects += subjects_for_current_grade.select { |subject| subject.start_with?(subject_key) }
    end
    subjects_has_schoolyear = []
    subjects.each do |subject|
      if grade == 'k' || subject.start_with?('geography_', 'history_', 'civics_') || subject.end_with?('_standard', '_high-level')
        subjects_has_schoolyear.push({ subject: subject, schoolyear: grade == 'k' ? 'k' : 'c1' })
      else
        %w(c1 c2 c3).each do |schoolyear|
          subjects_has_schoolyear.push({ subject: subject, schoolyear: schoolyear })
        end
      end
    end
    subjects_has_schoolyear
  end
end
