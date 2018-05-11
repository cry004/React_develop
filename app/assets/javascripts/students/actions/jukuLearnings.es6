export const REQUEST_JUKU_LEARNINGS_CURRENT = 'REQUEST_JUKU_LEARNINGS_CURRENT'
export const REQUEST_JUKU_LEARNINGS_ARCHIVES = 'REQUEST_JUKU_LEARNINGS_ARCHIVES'
export const RECEIVE_JUKU_LEARNINGS = 'RECEIVE_JUKU_LEARNINGS'
export const INIT_JUKU_LEARNINGS = 'INIT_JUKU_LEARNINGS'

export function requestJukuLearningsCurrent(accessToken = "",) {
  return {
    type: REQUEST_JUKU_LEARNINGS_CURRENT,
    accessToken: accessToken,
    isFetching: true
  }
}

export function requestJukuLearningsArchives(accessToken = "", page = 1, perPage = 20) {
  return {
    type: REQUEST_JUKU_LEARNINGS_ARCHIVES,
    accessToken: accessToken,
    page: page,
    perPage: perPage,
    isFetching: true
  }
}

export function receiveJukuLearnings(learnings = []) {
  return {
    type: RECEIVE_JUKU_LEARNINGS,
    learnings: learnings,
    isFetching: false
  }
}

export function initJukuLearnings() {
  return {
    type: INIT_JUKU_LEARNINGS
  }
}