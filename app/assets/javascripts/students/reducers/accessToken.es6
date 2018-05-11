import { SET_ACCESSTOKEN,
  INIT_ACCESS_TOKEN } from '../actions/accessToken.es6'

const initialState = {
  accessToken: '',
  isAccessToken: false
}

function accessToken(state = initialState, action) {
  switch (action.type) {
    case SET_ACCESSTOKEN:
      return Object.assign({}, state, {
        accessToken: action.accessToken,
        isAccessToken: action.isAccessToken
      })
    case INIT_ACCESS_TOKEN:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default accessToken