module EventLogHelper
  def question_event_log_data(question)
    return {} unless question.present?

    question_info = { question_id: question.id,
                      subject:     question.subject.try!(:name_and_type) }

    video_info  = video_event_log_data(question.video, question.position)
    answer_info = question_answer_event_log_data(question)

    question_info.merge(video_info).merge(answer_info)
  end

  def video_event_log_data(video, position = nil)
    return {} unless video.present?

    video_info = { video_id:       video.id,
                   subject:        video.subject.try!(:name_and_type),
                   schoolyear:     video.schoolyear_for_eventlog,
                   video_filename: video.filename }

    position_info = video_position_event_log_data(video, position)

    video_info.merge(position_info)
  end

  def video_position_event_log_data(video, position)
    return {} unless video.present? && position.present?

    { position:       position,
      chapter_number: video.chapter_num_of_incomprehensible(position) }
  end

  def question_answer_event_log_data(question)
    answer = question.try!(:posts).try!(:search_answers).try!(:take)
    return {} unless answer.present?

    { answer_id:     answer.id,
      answerer_id:   answer.postable_id,
      answerer_role: answer.postable.role,
      answerer_rank: answer.postable.rank }
  end

  def video_watched_log_data(video, viewed_time)
    return {} unless video.present?

    { video_id:       video.id,
      subject:        video.subject.try!(:name_and_type),
      schoolyear:     video.schoolyear_for_eventlog,
      video_filename: video.filename,
      viewed_time:    viewed_time }
  end
end
