import { UPDATE_CURRENT_QUESTION,
  REQUEST_QUESTION,
  RECEIVE_QUESTION,
  UPDATE_QUESTION_STATE,
  INIT_QUESTION } from '../actions/question.es6'

const initialState = {
  id: null,
  posts: [],
  resolvable: false,
  state: {},
  unread: false,
  isFetching: false
}

function question(state = initialState, action) {
  switch (action.type) {
    case UPDATE_CURRENT_QUESTION:
      return Object.assign({}, state, {
        id: action.id
      })
    case REQUEST_QUESTION:
      return Object.assign({}, state, {
        accessToken: action.accessToken,
        id: action.id,
        isFetching: true
      })
    case RECEIVE_QUESTION:
      return Object.assign({}, state, {
        posts: action.posts,
        resolvable: action.resolvable,
        state: action.state,
        subject: action.subject,
        unread: action.unread,
        isFetching: false
      })
    case UPDATE_QUESTION_STATE:
      return Object.assign({}, state, {
        state: action.state
      })
    case INIT_QUESTION:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default question