import { UPDATE_ALERTS } from '../actions/alerts.es6'

const initialState = {
  alerts: []
}

function alerts(state = initialState, action) {
  switch (action.type) {
    case UPDATE_ALERTS:
     return Object.assign({}, state, {
        alerts: action.alerts
     })
    default:
      return state
  }
}

export default alerts