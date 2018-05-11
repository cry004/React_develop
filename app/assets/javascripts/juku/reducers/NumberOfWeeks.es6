import { REQUEST_NUMBEROFWEEKS, RECIEVED_NUMBEROFWEEKS, NOTRECIEVED_NUMBEROFWEEKS } from '../actions/NumberOfWeeks.es6'

const initialState = {
  numberOfWeeks: 0
}

function requestNumberOfWeeks(state = initialState, action) {
  switch (action.type) {
    case REQUEST_NUMBEROFWEEKS:
      return Object.assign({}, state, {
      })
    case RECIEVED_NUMBEROFWEEKS:
      return Object.assign({}, state, {
        numberOfWeeks: action.numberOfWeeks
      })
    case NOTRECIEVED_NUMBEROFWEEKS:
      return Object.assign({}, state, {
      })
    default:
      return state
  }
}

export default requestNumberOfWeeks