import { 
  REQUEST_LEARNING_PROGRESSES,
  RECEIVE_LEARNING_PROGRESSES,
  UPDATE_LEARNING_PROGRESS_SUBJECT,
  INIT_LEARNING_PROGRESSES_ALL } from '../actions/learningProgresses.es6'

const initialState = {
  experiencePointForNextLevel: 1,
  lastLearningSubjects: [],
  learningTime: {
    hours: 0,
    minutes: 0
  },
  levelProgress: 0,
  watchedVideosCount: 0,
  student: {
    avatar: 0,
    level: 1,
    nick_name: "",
    school: "c",
    school_address: "",
    school_year: "中学1年生"
  },
  currentSubject: "english",
  isFetching: false
}

function learningProgresses(state = initialState, action) {
  switch (action.type) {
    case REQUEST_LEARNING_PROGRESSES:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_LEARNING_PROGRESSES:
      return Object.assign({}, state, {
        experiencePointForNextLevel: action.experiencePointForNextLevel,
        lastLearningSubjects: action.lastLearningSubjects,
        learningTime: action.learningTime,
        levelProgress: action.levelProgress,
        watchedVideosCount: action.watchedVideosCount,
        completedTrophiesCount: action.completedTrophiesCount,
        student: action.student,
        isFetching: action.isFetching
      })
    case UPDATE_LEARNING_PROGRESS_SUBJECT:
      return Object.assign({}, state, {
        currentSubject: action.currentSubject
      })
    case INIT_LEARNING_PROGRESSES_ALL:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default learningProgresses

