import { CHANGE_PDFLISTBTNDISABLE,
  REQUEST_LEARNINGS,
  RECIEVE_LEARNINGS,
  CHANGE_SETLEARNINGS,
  INIT_IS_FETCHED_LEARNINGS,
  INIT_LEARNINGS } from '../actions/Learnings.es6'

const initialState = {
  setLearnings: [],
  pdfListBtnDisable: true,
  isFetchedLearnings: false,
}

function requestLearnings(state = initialState, action) {
  switch (action.type) {
    case REQUEST_LEARNINGS:
      return Object.assign({}, state, {
      })
    case RECIEVE_LEARNINGS:
      return Object.assign({}, state, {
        setLearnings: action.setLearnings,
        isFetchedLearnings: action.isFetchedLearnings
      })
    case CHANGE_PDFLISTBTNDISABLE:
      return Object.assign({}, state, {
        pdfListBtnDisable: action.pdfListBtnDisable
      })
    case CHANGE_SETLEARNINGS:
      return Object.assign({}, state, {
        setLearnings: action.setLearnings
      })
    case INIT_IS_FETCHED_LEARNINGS:
      return Object.assign({}, state, {
        isFetchedLearnings: action.isFetchedLearnings
      })
    case INIT_LEARNINGS:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestLearnings