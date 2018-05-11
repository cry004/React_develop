module VideoHelper
  MIDDLE_SCHOOL_SOCIAL_SUBJECT = %w(geography history civics)
  HIGH_SCHOOL_SOCIAL_SUBJECT   = %w(sociology japanese_history world_history)
  HIGH_SCHOOL_SCIENCE_SUBJECT  = %w(physics chemistry biology)
  ENTRANCE_EXAM                = %w(standard high-level)

  def video_type(subject)
    subject_type = subject.type
    return I18n.t("subject_type_name.#{subject_type}") if subject.school == 'c'
    subject_type.in?(Subject::UNIVERCITY_EXAM_LIST) ? 'センター対策編' : '通常学習編'
  end

  def video_detail_name(video_schoolyear, subject)
    subject.school == 'c' ? video_name_middle_school(video_schoolyear, subject) : video_name_high_school(subject)
  end

  private

  def video_name_middle_school(video_schoolyear, subject)
    subject_detail_type  = I18n.t("subject_detail_name.#{subject.type}")
    subject_detail_name  = I18n.t("subject_detail_name.c.#{subject.name}")
    subject_is_social    = subject_is_social?(subject)
    type_regular_or_exam = subject_type_regular_or_exam?(subject)

    return subject_detail_name if type_regular_or_exam && subject_is_social

    return subject_detail_type + subject_detail_name if subject_is_social

    return I18n.t("subject_detail_name.#{video_schoolyear}") if type_regular_or_exam
    subject_detail_type
  end

  def video_name_high_school(subject)
    subject_name = subject.name
    subject_type = subject.type
    return I18n.t("subject_detail_name.k.#{subject_name}.#{subject_type}") if subject_name.in?(HIGH_SCHOOL_SCIENCE_SUBJECT)
    return I18n.t("subject_detail_name.k.#{subject_name}.#{subject_type}") unless subject_type.in?(ENTRANCE_EXAM)

    "#{I18n.t("subject_detail_name.#{subject_type}")}#{I18n.t("subject_detail_name.k.#{subject_name}")}"
  end

  def subject_type_regular_or_exam?(subject)
    subject.type.in? %w(regular exam)
  end

  def subject_is_social?(subject)
    subject.name.in?(MIDDLE_SCHOOL_SOCIAL_SUBJECT)
  end

  def locked_video?(current_student, schoolbook, video)
    return true if video.nil?
    return false if current_student.fist?
    return false unless video.subject.name_and_type.end_with?('standard', 'high-level')
    return false if schoolbook.units.flatten.map{ |unit| unit['videos'][0]['id'] }.include? video.id
    true
  end

  def subject_key_by_subject_name(subject_name)
    return 'social_studies' if subject_name.in?(MIDDLE_SCHOOL_SOCIAL_SUBJECT) || subject_name.in?(HIGH_SCHOOL_SOCIAL_SUBJECT)
    return 'science' if subject_name.in?(HIGH_SCHOOL_SCIENCE_SUBJECT)
    return subject_name.split('_').first if subject_name.in?(%w(english_writing mathematics_1a mathematics_2b english_listening))
    subject_name
  end

  def progress_for_units(unit, videos_watched_ids)
    video_ids_watched = videos_watched_ids
    video_ids = unit['videos'].map{ |video| video['id'] }
    video_ids == video_ids_watched & video_ids
  end
end
