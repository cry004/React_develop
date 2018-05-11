import { CHANGE_REPORTED_AT,
  POST_LEARNINGREPORT,
  REQUEST_LEARNINGREPORTS,
  RECEIVE_LEARNINGREPORTS,
  INIT_IS_FETCHED_REPORT,
  INIT_REPORT,
  INIT_IS_READY_TO_PRINT
   } from '../actions/Reports.es6'

const initialState = {
  access_token: {},
  box_id: '',
  report_date: '',
  student: {},
  agreement: {},
  curriculums: [],
  e_navis: {},
  reported_at: '',
  isFetchedReport: false,
  isReadyToPrint: false
}

function requestLearningReports(state = initialState, action) {
  switch (action.type) {
    case REQUEST_LEARNINGREPORTS:
      return Object.assign({}, state, {
      })
    case RECEIVE_LEARNINGREPORTS:
      return Object.assign({}, state, {
        box_id: action.box_id,
        report_date: action.report_date,
        student: action.student,
        agreement: action.agreement,
        curriculums: action.curriculums,
        e_navis: action.e_navis,
        isFetchedReport: action.isFetchedReport,
        isReadyToPrint: action.isReadyToPrint
      })
    case POST_LEARNINGREPORT:
      return Object.assign({}, state, {
        reported_at: action.reported_at,
        isReadyToPrint: action.isReadyToPrint
      })
    case CHANGE_REPORTED_AT:
      return Object.assign({}, state, {
        reported_at: action.reported_at
      })
    case INIT_IS_FETCHED_REPORT:
      return Object.assign({}, state, {
        isFetchedReport: action.isFetchedReport
      })
    case INIT_IS_READY_TO_PRINT:
      return Object.assign({}, state, {
        isReadyToPrint: action.isReadyToPrint
      })
    case INIT_REPORT:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestLearningReports
