import { SHOW_POPUP,
  HIDE_POPUP } from '../actions/popup.es6'

const initialState = {
  isHidden: true,
  popupType: "",
  args: {}
}

function popup(state = initialState, action) {
  switch (action.type) {
    case SHOW_POPUP:
      return Object.assign({}, state, {
        isHidden: action.isHidden,
        popupType: action.popupType,
        args: action.args
      })
    case HIDE_POPUP:
      return Object.assign({}, state, {
        isHidden: action.isHidden
      })
    default:
      return state
  }
}

export default popup