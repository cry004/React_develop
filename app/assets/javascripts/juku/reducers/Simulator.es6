import { 
        CHANGE_START_DATE, 
        CHANGE_END_DATE, 
        CHANGE_ISCALSTARTACTIVE,
        CHANGE_ISCALENDACTIVE, 
        CHANGE_CALACIVE,
        CHANGE_ISCALACTIVE,
        REQUEST_SUBJECTS,
        RECEIVE_SUBJECTS,
        CHANGE_CHECKEDSUBUNITS,
        INIT_SIMULATOR } from '../actions/Simulator.es6'
import moment from 'moment'
import { getToday } from '../utils/Utils.js'

const initialState = {
  isCalStartActive: false,
  isCalEndActive: false,
  start_date: moment().format('YYYY-MM-DD'),
  end_date: moment().add(3, 'months').format('YYYY-MM-DD'),
  isCalActive: false,
  sub_subjects: [],
  units: [],
  checkedSubUnits: [],
  subject_val: "c1_english_regular",
  isFetchedSubjects: false
}

function requestSimulator(state = initialState, action) {
  switch (action.type) {
    case CHANGE_START_DATE:
      return Object.assign({}, state, {
        start_date: action.start_date
      })
    case CHANGE_END_DATE:
      return Object.assign({}, state, {
        end_date: action.end_date
      })
    case CHANGE_ISCALSTARTACTIVE:
      return Object.assign({}, state, {
        isCalStartActive: action.isCalStartActive
      })
    case CHANGE_ISCALENDACTIVE:
      return Object.assign({}, state, {
        isCalEndActive: action.isCalEndActive
      })
    case CHANGE_CALACIVE:
      return Object.assign({}, state, {
        isCalStartActive: action.isCalStartActive,
        isCalEndActive: action.isCalEndActive
      })
    case CHANGE_ISCALACTIVE:
      return Object.assign({}, state, {
        isCalActive: action.isCalActive
      })
    case REQUEST_SUBJECTS:
      return Object.assign({}, state, {
        access_token: action.access_token,
        subject_val: action.subject_val,
        isFetchedSubjects: false
      })
    case RECEIVE_SUBJECTS:
      return Object.assign({}, state, {
        sub_subjects: action.sub_subjects,
        units: action.units,
        isFetchedSubjects: true
      })
    case CHANGE_CHECKEDSUBUNITS:
      return Object.assign({}, state, {
        checkedSubUnits: action.checkedSubUnits
      })
    case INIT_SIMULATOR:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestSimulator