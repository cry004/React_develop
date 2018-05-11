export const INIT_HISTORIES = 'INIT_HISTORIES'
export const REQUEST_HISTORIES = 'REQUEST_HISTORIES'
export const RECEIVE_HISTORIES = 'RECEIVE_HISTORIES'
export const DELETE_HISTORY = 'DELETE_HISTORY'

export function initHistories() {
  return {
    type: INIT_HISTORIES,
    videos: []
  }
}

export function requestHistories(accessToken = "", page = 1, perPage = 20) {
  return {
    type: REQUEST_HISTORIES,
    accessToken: accessToken,
    page: page,
    perPage: perPage,
    isFetching: true
  }
}

export function receiveHistories(videos) {
  return {
    type: RECEIVE_HISTORIES,
    videos: videos,
    isFetching: false
  }
}

export function deleteHistory(accessToken = "", deletedId = null) {
  return {
    type: DELETE_HISTORY,
    accessToken: accessToken,
    deletedId: deletedId
  }
}