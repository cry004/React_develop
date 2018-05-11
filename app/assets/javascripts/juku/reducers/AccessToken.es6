import { SET_ACCESSTOKEN, FROM_TRYPLUS, INIT_FROM_TRYPLUS } from '../actions/AccessToken.es6'

const initialState = {
  access_token: '',
  isAccessToken: false,
  isFromTryPlus: false
}

function requestAccessToken(state = initialState, action) {
  switch (action.type) {
    case SET_ACCESSTOKEN:
      return Object.assign({}, state, {
        access_token: action.access_token,
        isAccessToken: action.isAccessToken
      })
    case FROM_TRYPLUS:
      return Object.assign({}, state, {
        isFromTryPlus: action.isFromTryPlus
      })
    case INIT_FROM_TRYPLUS:
      return Object.assign({}, state, {
        isFromTryPlus: false
      })
    default:
      return state
  }
}

export default requestAccessToken
