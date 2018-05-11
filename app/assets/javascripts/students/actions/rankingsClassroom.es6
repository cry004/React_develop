export const UPDATE_CURRENT_RANKING_CLASSROOM_TERM = 'UPDATE_CURRENT_RANKING_CLASSROOM_TERM'
export const UPDATE_CURRENT_RANKING_CLASSROOM_TAB = 'UPDATE_CURRENT_RANKING_CLASSROOM_TAB'
export const REQUEST_RANKINGS_CLASSROOM = 'REQUEST_RANKINGS_CLASSROOM'
export const RECEIVE_RANKINGS_CLASSROOM = 'RECEIVE_RANKINGS_CLASSROOM'
export const REQUEST_RANKINGS_CLASSROOMS = 'REQUEST_RANKINGS_CLASSROOMS'
export const RECEIVE_RANKINGS_CLASSROOMS = 'RECEIVE_RANKINGS_CLASSROOMS'
export const INIT_RANKINGS_CLASSROOM = 'INIT_RANKINGS_CLASSROOM'

export function updateCurrentRankingClassroomTerm(currentTerm) {
  return {
    type: UPDATE_CURRENT_RANKING_CLASSROOM_TERM,
    currentTerm: currentTerm
  }
}

export function updateCurrentRankingClassroomTab(currentTab) {
  return {
    type: UPDATE_CURRENT_RANKING_CLASSROOM_TAB,
    currentTab: currentTab
  }
}

export function requestRankingsClassroom(accessToken = "", region = "prefecture", term = "last_7_days", classroomType = "classroom") {
  return {
    type: REQUEST_RANKINGS_CLASSROOM,
    accessToken: accessToken,
    region: region,
    term: term,
    classroomType: classroomType,
    isFetching: true
  }
}
export function receiveRankingsClassroom(data) {
  return {
    type: RECEIVE_RANKINGS_CLASSROOM,
    rankings: data.rankings || [],
    isFetching: false
  }
}

export function requestRankingsClassrooms(accessToken = "", term = "last_7_days") {
  return {
    type: REQUEST_RANKINGS_CLASSROOMS,
    accessToken: accessToken,
    term: term
  }
}
export function receiveRankingsClassrooms(data) {
  return {
    type: RECEIVE_RANKINGS_CLASSROOMS,
    rankingMonth: data.ranking_month,
    classroom: data.classroom,
    rankingDate: data.ranking_date,
    learningTime: data.learning_time,
    currentClassroomRankings: data.current_classroom_rankings,
    rankingChanges: data.ranking_changes
  }
}


export function initRankingsClassroom() {
  return {
    type: INIT_RANKINGS_CLASSROOM
  }
}