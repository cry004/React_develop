import moment from 'moment'

import { CHANGE_EDITCALACIVE, 
  POST_CURRICULUMS, 
  POSTED_CURRICULUMS, 
  CHANGE_CHECKEDSUBUNITS, 
  CHANGE_YOUTUBEURL, 
  REQUEST_CURRICULUMS, 
  RECEIVE_CURRICULUMS,
  CHANGE_ISYOUTUBEMODAL, 
  CHANGE_ISSETTINGMODAL,
  CHANGE_ISRESETMODAL,
  CHANGE_ISPDFMODAL,
  CHANGE_CURRICULUM_START_DATE,
  CHANGE_CURRICULUM_END_DATE,
  RECIEVED_NUMBEROFWEEKS,
  CHANGE_SUBSUBJECTS,
  CHANGE_LEARNINGSTATUS,
  PUTTED_LEARNINGSTATUS,
  CHANGE_SELECTED_AGREEMENT_ID,
  PUT_CURRICULUMS,
  PUTTED_CURRICULUMS,
  NOTPUTTED_CURRICULUMS,
  CHANGE_ISCALSTARTACTIVE,
  CHANGE_ISCALENDACTIVE,
  INIT_IS_FETCHED_CURRICULUMS,
  INIT_CURRICULUMS } from '../actions/Curriculums.es6'

const initialState = {
  box_id: '',
  student: {},
  agreement: {},
  sub_subjects: [],
  curriculum: {},
  learnings: {},
  isYoutubeModal: false,
  isSettingModal: false,
  isResetModal: false,
  isPdfModal: false,
  youtubeURL: 'https://www.youtube.com/embed/dR4wW2Cl7qY',
  checkedSubUnits: [],
  isCalStartActive: false,
  isCalEndActive: false,
  selected_sub_subject_key: '',
  selected_sub_subject_name: '',
  curEditStartDate: moment(new Date()).format('YYYY-MM-DD'),
  curEditEndDate: moment(new Date()).add(3, 'months').format('YYYY-MM-DD'),
  isFetchedCurriculums: false
}

function requestCurriculums(state = initialState, action) {
  switch (action.type) {
    case REQUEST_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case RECEIVE_CURRICULUMS:
      return Object.assign({}, state, {
        box_id: action.box_id,
        student: action.student,
        agreement: action.agreement,
        sub_subjects: action.sub_subjects,
        curriculum: action.curriculum,
        learnings: action.learnings,
        selected_sub_subject_key: action.selected_sub_subject_key,
        selected_sub_subject_name: action.selected_sub_subject_name,
        isFetchedCurriculums: action.isFetchedCurriculums
      })
    case CHANGE_SUBSUBJECTS:
      return Object.assign({}, state, {
        selected_sub_subject_key: action.selected_sub_subject_key,
        selected_sub_subject_name: action.selected_sub_subject_name
      })
    case CHANGE_CHECKEDSUBUNITS:
      return Object.assign({}, state, {
        checkedSubUnits: action.checkedSubUnits
      })
    case CHANGE_ISYOUTUBEMODAL:
      return Object.assign({}, state, {
        isYoutubeModal: action.isYoutubeModal
      })
    case CHANGE_YOUTUBEURL:
      return Object.assign({}, state, {
        youtubeURL: action.youtubeURL
      })
    case CHANGE_ISRESETMODAL:
      return Object.assign({}, state, {
        isResetModal: action.isResetModal
      })
    case CHANGE_ISSETTINGMODAL:
      return Object.assign({}, state, {
        isSettingModal: action.isSettingModal
      })
    case POST_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case POSTED_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case PUT_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case PUTTED_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case NOTPUTTED_CURRICULUMS:
      return Object.assign({}, state, {
      })
    case CHANGE_EDITCALACIVE:
      return Object.assign({}, state, {
        isCalStartActive: action.isCalStartActive,
        isCalEndActive: action.isCalEndActive
      })
    case CHANGE_CURRICULUM_START_DATE:
      return Object.assign({}, state, {
        curEditStartDate: action.curEditStartDate
      })
    case CHANGE_CURRICULUM_END_DATE:
      return Object.assign({}, state, {
        curEditEndDate: action.curEditEndDate
      })
    case RECIEVED_NUMBEROFWEEKS:
      return Object.assign({}, state, {
        numberOfWeeks: action.numberOfWeeks
      })
    case CHANGE_ISPDFMODAL:
      return Object.assign({}, state, {
        isPdfModal: action.isPdfModal
      })
    case CHANGE_LEARNINGSTATUS:
      return Object.assign({}, state, {
      })
    case PUTTED_LEARNINGSTATUS:
      return Object.assign({}, state, {
        learnings: action.learnings
      })
    case CHANGE_SELECTED_AGREEMENT_ID:
      return Object.assign({}, state, {
        agreement: action.agreement
      })
    case CHANGE_ISCALSTARTACTIVE:
      return Object.assign({}, state, {
        isCalStartActive: action.isCalStartActive
      })
    case CHANGE_ISCALENDACTIVE:
      return Object.assign({}, state, {
        isCalEndActive: action.isCalEndActive
      })
    case INIT_IS_FETCHED_CURRICULUMS:
      return Object.assign({}, state, {
        isFetchedCurriculums: action.isFetchedCurriculums
      })
    case INIT_CURRICULUMS:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestCurriculums