import moment from 'moment'

import { 
  CHANGE_HISTORY_SUBJECT_ID, 
  CHANGE_HISTORY_STATUS,
  CHANGE_HISTORYCALACIVE,
  CHANGE_HISTORY_END_DATE,
  CHANGE_HISTORY_START_DATE,
  REQUEST_HISTORIES,
  RECEIVE_HISTORIES,
  INIT_IS_FETCHED_HISTORIES,
  INIT_HISTORIES } from '../actions/History.es6'

const initialState = {
  historyLearnings: [],
  historySubjects: [],
  historyStartDate: moment().subtract(3, 'months').format('YYYY-MM-DD'),
  historyEndDate: moment().format('YYYY-MM-DD'),
  isHistoryCalStartActive: false,
  isHistoryCalEndActive: false,
  historyStatus: null,
  historySubjectID: null,
  isFetchedHistories: false
}

function requestAccessToken(state = initialState, action) {
  switch (action.type) {
    case REQUEST_HISTORIES:
      return Object.assign({}, state, {
      })
    case RECEIVE_HISTORIES:
      return Object.assign({}, state, {
        historyLearnings: action.historyLearnings,
        historySubjects: action.historySubjects,
        isFetchedHistories: action.isFetchedHistories
      })
    case CHANGE_HISTORYCALACIVE:
      return Object.assign({}, state, {
        isHistoryCalStartActive: action.isHistoryCalStartActive,
        isHistoryCalEndActive: action.isHistoryCalEndActive
      })
    case CHANGE_HISTORY_START_DATE:
      return Object.assign({}, state, {
        historyStartDate: action.historyStartDate
      })
    case CHANGE_HISTORY_END_DATE:
      return Object.assign({}, state, {
        historyEndDate: action.historyEndDate
      })
    case CHANGE_HISTORY_SUBJECT_ID:
      return Object.assign({}, state, {
        historySubjectID: action.historySubjectID
      })
    case CHANGE_HISTORY_STATUS:
      return Object.assign({}, state, {
        historyStatus: action.historyStatus
      })
    case INIT_IS_FETCHED_HISTORIES:
      return Object.assign({}, state, {
        isFetchedHistories: action.isFetchedHistories
      })
    case INIT_HISTORIES:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestAccessToken