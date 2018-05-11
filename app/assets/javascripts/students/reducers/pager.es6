import { UPDATE_CURRENT_PAGE,
  IS_LAST_PAGE,
  INIT_PAGER } from '../actions/pager.es6'

const initialState = {
  currentPage: '1',
  isLastPage: false
}

function pager(state = initialState, action) {
  switch (action.type) {
    case UPDATE_CURRENT_PAGE:
      return Object.assign({}, state, {
        currentPage: action.currentPage
      })
    case IS_LAST_PAGE:
      return Object.assign({}, state, {
        isLastPage: action.isLastPage
      })
    case INIT_PAGER:
      return initialState
    default:
      return state
  }
}

export default pager