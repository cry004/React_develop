import { ADD_ERROR_MESSAGE, INIT_ERROR_MESSAGE } from '../actions/ErrorMessage.es6'

const initialState = {
  errors: []
}

function requestErrorMessage(state = initialState, action) {
  switch (action.type) {
    case ADD_ERROR_MESSAGE:
      return Object.assign({}, state, {
        errors: action.errors
      })
    case INIT_ERROR_MESSAGE:
      return Object.assign({}, state, {
        errors: []
      })
    default:
      return state
  }
}

export default requestErrorMessage