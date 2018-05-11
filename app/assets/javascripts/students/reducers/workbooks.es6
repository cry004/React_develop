import { RECEIVE_WORKBOOKS } from '../actions/workbooks.es6'

const initialState = {
  subjects: []
}

function workbooks(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_WORKBOOKS:
      return Object.assign({}, state, {
        subjects: action.subjects
      })
    default:
      return state
  }
}

export default workbooks