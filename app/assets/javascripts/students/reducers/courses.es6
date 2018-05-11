import { RECEIVE_COURSES,
  } from '../actions/courses.es6'

const initialState = {
  courses: {
    english: [], 
    japanese: [],
    mathematics: [],
    science: [],
    social_studies: []
  }
}

function courses(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_COURSES:
     return Object.assign({}, state, {
        courses: action.courses
     })
    default:
      return state
  }
}

export default courses