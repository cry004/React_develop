import { CHANGE_BOX_ID, 
  REQUEST_BOXES, 
  RECEIVE_BOXES, 
  CHANGE_ISCALACTIVE, 
  CHANGE_SCHEDULE_TYPE, 
  SELECTED_BOX, 
  CHANGE_SELECTED_AGREEMENT_ID,
  INIT_IS_FETCHED_BOX,
  INIT_BOX_STATE } from '../actions/Boxes.es6'
import { getToday } from '../utils/Utils.js'

const initialState = {
  isFetchedBox: false,
  items: [],
  periods: [],
  start_date: getToday(),
  end_date: getToday(),
  schedule_type: 'day',
  selected_box_id: '',
  selected_subject_id: '',
  selected_schoolyear_key: '',
  selected_agreement_id: '',
  selected_student_id: '',
  selected_student_name: '',
  selected_period_id: '',
  isCalActive: false,
  selected_date: ''
}

function requestBoxes(state = initialState, action) {
  switch (action.type) {
    case REQUEST_BOXES:
      return Object.assign({}, state, {
        start_date: action.start_date,
        end_date: action.end_date
      })
    case RECEIVE_BOXES:
      return Object.assign({}, state, {
        items: action.items,
        periods: action.periods,
        isFetchedBox: action.isFetchedBox
      })
    case SELECTED_BOX: 
      return Object.assign({}, state, {
        selected_student_id: action.selected_student_id,
        selected_box_id: action.selected_box_id,
        selected_subject_id: action.selected_subject_id,
        selected_student_name: action.selected_student_name,
        selected_schoolyear_key: action.selected_schoolyear_key,
        selected_agreement_id: action.selected_agreement_id,
        selected_period_id: action.selected_period_id,
        selected_date: action.selected_date
      })
    case CHANGE_ISCALACTIVE:
      return Object.assign({}, state, {
        isCalActive: action.isCalActive
      })
    case CHANGE_SCHEDULE_TYPE:
      return Object.assign({}, state, {
        schedule_type: action.schedule_type
      })
    case CHANGE_BOX_ID:
      return Object.assign({}, state, {
        selected_box_id: action.selected_box_id
      })
    case CHANGE_SELECTED_AGREEMENT_ID:
      return Object.assign({}, state, {
        selected_agreement_id: action.selected_agreement_id
      })
    case INIT_IS_FETCHED_BOX:
      return Object.assign({}, state, {
        isFetchedBox: action.isFetchedBox
      })
    case INIT_BOX_STATE:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestBoxes