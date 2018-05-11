import { SHOW_EXPERIENCE,
  HIDE_EXPERIENCE } from '../actions/level.es6'

const initialState = {
  experience: 0,
  experienceIsShow: false
}

function level(state = initialState, action) {
  switch (action.type) {
    case SHOW_EXPERIENCE:
      return Object.assign({}, state, {
        experience: action.experience,
        experienceIsShow: action.experienceIsShow
      })
    case HIDE_EXPERIENCE:
      return Object.assign({}, state, {
        experienceIsShow: action.experienceIsShow
      })
    default:
      return state
  }
}

export default level