import { 
  REQUEST_LOGIN,
  REQUEST_LOGOUT,
  LOGIN_ERROR_MESSAGE,
  INIT_LOGIN } from '../actions/login.es6'

const initialState = {
  errorMessage: "",
  isSending: false
}

function login(state = initialState, action) {
  switch (action.type) {
    case REQUEST_LOGIN:
      return Object.assign({}, state, {
        isSending: action.isSending
      })
    case LOGIN_ERROR_MESSAGE:
      return Object.assign({}, state, {
        errorMessage: action.errorMessage,
        isSending: action.isSending
      })
    case INIT_LOGIN:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default login