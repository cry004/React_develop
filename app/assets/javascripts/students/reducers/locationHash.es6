import { UPDATE_LOCATION_HASH } from '../actions/locationHash.es6'

const initialState = {
  current: "",
  prev: ""
}

function locationHash(state = initialState, action) {
  switch (action.type) {
    case UPDATE_LOCATION_HASH:
      return Object.assign({}, state, {
        current: action.current,
        prev: state.current,
      })
    default:
      return state
  }
}

export default locationHash