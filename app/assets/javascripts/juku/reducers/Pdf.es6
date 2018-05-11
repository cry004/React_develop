import { 
  DEFAULT_PDF, 
  YES_PDF,
  NO_PDF,
  CHECK_PDF,
  JOIN_PDF,
  JOINED_PDF,
  ERRORD_JOIN_PDF } from '../actions/Pdf.es6'

const initialState = {
  joinedPdfResponceStatus: 999,
  joinedPdfUrl: '',
  isJoinedPdfStatus: 'default',
  checkCount: 0,
  errorMessage: ''
}

function requestPdf(state = initialState, action) {
  switch (action.type) {
    case JOIN_PDF:
      return Object.assign({}, state, {
        isJoinedPdfStatus: 'loading',
        checkCount: 0
      })
    case JOINED_PDF:
      return Object.assign({}, state, {
        joinedPdfUrl: action.json.url
      })
    case CHECK_PDF:
      let newCheckCount = state.checkCount + 1
      return Object.assign({}, state, {
        joinedPdfUrl: action.url,
        checkCount: newCheckCount
      })
    case ERRORD_JOIN_PDF:
      return Object.assign({}, state, {
      })
    case DEFAULT_PDF:
      return Object.assign({}, state, {
        isJoinedPdfStatus: 'default'
      })
    case YES_PDF:
      return Object.assign({}, state, {
        isJoinedPdfStatus: 'yes'
      })
    case NO_PDF:
      return Object.assign({}, state, {
        isJoinedPdfStatus: 'no',
        joinedPdfResponceStatus: action.status,
        errorMessage: action.errorMessage
      })
    default:
      return state
  }
}

export default requestPdf