export const UPDATE_CURRENT_RANKING_TERM = 'UPDATE_CURRENT_RANKING_TERM'
export const UPDATE_CURRENT_RANKING_TAB = 'UPDATE_CURRENT_RANKING_TAB'
export const REQUEST_RANKINGS_PERSONAL = 'REQUEST_RANKINGS_PERSONAL'
export const RECEIVE_RANKINGS_PERSONAL = 'RECEIVE_RANKINGS_PERSONAL'
export const REQUEST_RANKINGS_PERSONALS = 'REQUEST_RANKINGS_PERSONALS'
export const RECEIVE_RANKINGS_PERSONALS = 'RECEIVE_RANKINGS_PERSONALS'
export const INIT_RANKINGS = 'INIT_RANKINGS'

export function updateCurrentRankingTerm(currentTerm) {
  return {
    type: UPDATE_CURRENT_RANKING_TERM,
    currentTerm: currentTerm
  }
}

export function updateCurrentRankingTab(currentTab) {
  return {
    type: UPDATE_CURRENT_RANKING_TAB,
    currentTab: currentTab
  }
}

export function requestRankingsPersonal(accessToken = "", region = "prefecture", term = "last_7_days") {
  return {
    type: REQUEST_RANKINGS_PERSONAL,
    accessToken: accessToken,
    region: region,
    term: term,
    isFetching: true
  }
}
export function receiveRankingsPersonal(data) {
  return {
    type: RECEIVE_RANKINGS_PERSONAL,
    rankings: data.rankings || [],
    isFetching: false
  }
}

export function requestRankingsPersonals(accessToken = "", term = "last_7_days") {
  return {
    type: REQUEST_RANKINGS_PERSONALS,
    accessToken: accessToken,
    term: term
  }
}
export function receiveRankingsPersonals(data) {
  return {
    type: RECEIVE_RANKINGS_PERSONALS,
    student: data.student,
    rankingMonth: data.ranking_month,
    learningTime: data.learning_time,
    rankingDate: data.ranking_date,
    currentStudentRankings: data.current_student_rankings,
    rankingChanges: data.ranking_changes
  }
}

export function initRankings() {
  return {
    type: INIT_RANKINGS
  }
}