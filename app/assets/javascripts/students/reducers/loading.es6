import { IS_SHOW_LOADING } from '../actions/loading.es6'

const initialState = {
  isShowLoading: false
}

function loading(state = initialState, action) {
  switch (action.type) {
    case IS_SHOW_LOADING:
      return Object.assign({}, state, {
        isShowLoading: action.isShowLoading
     })
    default:
      return state
  }
}

export default loading