import { INIT_SCROLL_LEFT, SCROLL_LEFT } from '../actions/scroll.es6'

const initialState = {
  left: - window.pageXOffset
}

function scroll(state = initialState, action) {
  switch (action.type) {
    case SCROLL_LEFT:
      return Object.assign({}, state, {
        left: action.left
      })
    case INIT_SCROLL_LEFT:
      return Object.assign({}, state, {
        left: 0
      })
    default:
      return state
  }
}

export default scroll