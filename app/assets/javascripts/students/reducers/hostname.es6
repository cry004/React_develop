import { INIT_HOST_NAME } from '../actions/hostname.es6'
const body = document.getElementById('body')
const initialState = {
  www: body.getAttribute('data-www-host')
}

function hostname(state = initialState, action) {
  switch (action.type) {
    case INIT_HOST_NAME:
      return initialState
    default:
      return state
  }
}

export default hostname