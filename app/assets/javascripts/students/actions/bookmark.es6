export const DELETE_BOOKMARK = 'DELETE_BOOKMARK'
export const REQUEST_BOOKMARKS = 'REQUEST_BOOKMARKS'
export const RECEIVE_BOOKMARKS = 'RECEIVE_BOOKMARKS'
export const INIT_BOOKMARKS = 'INIT_BOOKMARKS'
export const DELETED_BOOKMARK = 'DELETED_BOOKMARK'

export function deleteBookmark(accessToken = "", videoId) {
  return {
    type: DELETE_BOOKMARK,
    accessToken: accessToken,
    videoId: videoId,
  }
}

export function requestBookmarks(accessToken = "", maxId = null , perPage = 15) {
  return {
    type: REQUEST_BOOKMARKS,
    accessToken: accessToken,
    maxId: maxId,
    perPage: perPage,
    isFetching: true
  }
}

export function receiveBookmarks(videos) {
  return {
    type: RECEIVE_BOOKMARKS,
    videos: videos,
    isFetching: false
  }
}

export function initBookmarks() {
  return {
    type: INIT_BOOKMARKS,
    videos: []
  }
}

export function deletedBookmark(deletedId = null) {
  return {
    type: DELETED_BOOKMARK,
    deletedId: deletedId
  }
}