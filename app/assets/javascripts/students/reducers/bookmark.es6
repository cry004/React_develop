import _ from 'lodash'

import { 
  REQUEST_BOOKMARKS,
  RECEIVE_BOOKMARKS,
  INIT_BOOKMARKS,
  DELETED_BOOKMARK } from '../actions/bookmark.es6'

const initialState = {
  videos: [],
  isFetching: false
}

function bookmark(state = initialState, action) {
  switch (action.type) {
    case REQUEST_BOOKMARKS:
     return Object.assign({}, state, {
        isFetching: action.isFetching
     })
    case RECEIVE_BOOKMARKS:
      return Object.assign({}, state, {
        videos: state.videos.concat(action.videos),
        isFetching: action.isFetching
     })
    case INIT_BOOKMARKS:
     return Object.assign({}, state, {
        videos: action.videos
     })
    case DELETED_BOOKMARK:
      const videos = _.remove(state.videos, (video) => {
          return video.video_id !== action.deletedId
        }
      )
      return Object.assign({}, state, {
        videos: videos
      })
    default:
      return state
  }
}

export default bookmark