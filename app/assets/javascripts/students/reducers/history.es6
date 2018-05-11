import _ from 'lodash'

import { INIT_HISTORIES,
  REQUEST_HISTORIES,
  RECEIVE_HISTORIES } from '../actions/history.es6'

const initialState = {
  videos: [],
  isFetching: false
}

function history(state = initialState, action) {
  switch (action.type) {
    case INIT_HISTORIES:
      return Object.assign({}, state, {
        videos: action.videos
      })    
    case REQUEST_HISTORIES:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_HISTORIES:
      return Object.assign({}, state, {
        videos: state.videos.concat(action.videos),
        isFetching: action.isFetching
      })
    default:
      return state
  }
}

export default history