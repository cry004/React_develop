export const REQUEST_LEARNING_PROGRESSES = 'REQUEST_LEARNING_PROGRESSES'
export const RECEIVE_LEARNING_PROGRESSES = 'RECEIVE_LEARNING_PROGRESSES'
export const INIT_LEARNING_PROGRESSES_ALL = 'INIT_LEARNING_PROGRESSES_ALL'
export const UPDATE_LEARNING_PROGRESS_SUBJECT = 'UPDATE_LEARNING_PROGRESS_SUBJECT'

export function requestLearningProgresses(accessToken = "") {
  return {
    type: REQUEST_LEARNING_PROGRESSES,
    accessToken: accessToken,
    isFetching: true
  }
}

export function receiveLearningProgresses(data) {
  return {
    type: RECEIVE_LEARNING_PROGRESSES,
    experiencePointForNextLevel: data.experience_point_for_next_level,
    lastLearningSubjects: data.last_learning_subjects,
    learningTime: data.learning_time,
    levelProgress: data.level_progress,
    watchedVideosCount: data.watched_videos_count,
    completedTrophiesCount: data.completed_trophies_count,
    student: {
      avatar: data.student.avatar,
      level: data.student.level,
      nickName: data.student.nick_name,
      school: data.student.school,
      schoolAddress: data.student.school_address,
      schoolYear: data.student.school_year,
      classroomName: data.student.classroom_name || 'Try IT 会員'
    },
    isFetching: false
  }
}

export function updateLearningProgressSubject(subject) {
  return {
    type: UPDATE_LEARNING_PROGRESS_SUBJECT,
    currentSubject: subject
  }
}

export function initLearningProgressAll() {
  return {
    type: INIT_LEARNING_PROGRESSES_ALL
  }
}