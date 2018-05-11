import { INIT_JUKU_LEARNINGS,
  REQUEST_JUKU_LEARNINGS_CURRENT,
  REQUEST_JUKU_LEARNINGS_ARCHIVES,
  RECEIVE_JUKU_LEARNINGS } from '../actions/jukuLearnings.es6'

const initialState = {
  learnings: [],
  isFetching: false
}

function jukuLearnings(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_JUKU_LEARNINGS:
      return Object.assign({}, state, {
        learnings: action.learnings,
        isFetching: action.isFetching
      })
    case REQUEST_JUKU_LEARNINGS_CURRENT:
      return Object.assign({}, state, {        
        isFetching: action.isFetching
      })
    case REQUEST_JUKU_LEARNINGS_ARCHIVES:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case INIT_JUKU_LEARNINGS:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default jukuLearnings