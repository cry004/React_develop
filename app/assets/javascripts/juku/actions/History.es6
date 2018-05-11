export const REQUEST_HISTORIES = 'REQUEST_HISTORIES'
export const RECEIVE_HISTORIES = 'RECEIVE_HISTORIES'
export const CHANGE_HISTORY_START_DATE = 'CHANGE_HISTORY_START_DATE'
export const CHANGE_HISTORY_END_DATE = 'CHANGE_HISTORY_END_DATE'
export const CHANGE_HISTORYCALACIVE = 'CHANGE_HISTORYCALACIVE'
export const CHANGE_HISTORY_STATUS = 'CHANGE_HISTORY_STATUS'
export const CHANGE_HISTORY_SUBJECT_ID = 'CHANGE_HISTORY_SUBJECT_ID'
export const INIT_IS_FETCHED_HISTORIES = 'INIT_IS_FETCHED_HISTORIES'
export const INIT_HISTORIES = 'INIT_HISTORIES'

//アクションクリエーター
export function requestHistories(access_token, student_id, start_date = null, end_date = null, subject_id = null, status = null) {
  return {
    type: REQUEST_HISTORIES,
    access_token,
    student_id, start_date, end_date, subject_id, status
  }
}

export function receiveHistories(json) {
  return {
    type: RECEIVE_HISTORIES,
    histories: json,
    historyLearnings: json.data.learnings,
    historySubjects: json.data.subjects,
    isFetchedHistories: true
  }
}

export function changeHistoryStartDate(start_date) {
  return {
    type: CHANGE_HISTORY_START_DATE,
    historyStartDate: start_date
  }
}

export function changeHistoryEndDate(end_date) {
  return {
    type: CHANGE_HISTORY_END_DATE,
    historyEndDate: end_date
  }
}

export function changeHistoryStatus(status) {
  return {
    type: CHANGE_HISTORY_STATUS,
    historyStatus: status
  }
}

export function changeHistorySubjectID(subject_id) {
  return {
    type: CHANGE_HISTORY_SUBJECT_ID,
    historySubjectID: subject_id
  }
}

export function setHistoryCalActive(isHistoryCalStartActive, isHistoryCalEndActive) {
  return {
    type: CHANGE_HISTORYCALACIVE,
    isHistoryCalStartActive: isHistoryCalStartActive,
    isHistoryCalEndActive: isHistoryCalEndActive
  }
}

export function initIsFetchedHistories() {
  return {
    type: INIT_IS_FETCHED_HISTORIES,
    isFetchedHistories: false
  }
}

export function initHistories() {
  return {
    type: INIT_HISTORIES
  }
}