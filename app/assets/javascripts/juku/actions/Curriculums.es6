export const REQUEST_CURRICULUMS = 'REQUEST_CURRICULUMS'
export const RECEIVE_CURRICULUMS = 'RECEIVE_CURRICULUMS'
export const CHANGE_ISYOUTUBEMODAL = 'CHANGE_ISYOUTUBEMODAL'
export const CHANGE_ISSETTINGMODAL = 'CHANGE_ISSETTINGMODAL'
export const CHANGE_ISRESETMODAL = 'CHANGE_ISRESETMODAL'
export const CHANGE_YOUTUBEURL = 'CHANGE_YOUTUBEURL'
export const CHANGE_CHECKEDSUBUNITS = 'CHANGE_CHECKEDSUBUNITS'
export const POST_CURRICULUMS = 'POST_CURRICULUMS'
export const POSTED_CURRICULUMS = 'POSTED_CURRICULUMS'
export const CHANGE_EDITCALACIVE = 'CHANGE_EDITCALACIVE'
export const CHANGE_CURRICULUM_START_DATE = 'CHANGE_CURRICULUM_START_DATE'
export const CHANGE_CURRICULUM_END_DATE = 'CHANGE_CURRICULUM_END_DATE'
export const RECIEVED_NUMBEROFWEEKS = 'RECIEVED_NUMBEROFWEEKS'
export const CHANGE_ISPDFMODAL = 'CHANGE_ISPDFMODAL'
export const CHANGE_SUBSUBJECTS = 'CHANGE_SUBSUBJECTS'
export const CHANGE_LEARNINGSTATUS = 'CHANGE_LEARNINGSTATUS'
export const PUTTED_LEARNINGSTATUS = 'PUTTED_LEARNINGSTATUS'
export const PUT_CURRICULUMS = 'PUT_CURRICULUMS'
export const PUTTED_CURRICULUMS = 'PUTTED_CURRICULUMS'
export const NOTPUTTED_CURRICULUMS = 'NOTPUTTED_CURRICULUMS'
export const CHANGE_ISCALSTARTACTIVE = 'CHANGE_ISCALSTARTACTIVE'
export const CHANGE_ISCALENDACTIVE = 'CHANGE_ISCALENDACTIVE'
export const INIT_IS_FETCHED_CURRICULUMS = 'INIT_IS_FETCHED_CURRICULUMS'
export const INIT_CURRICULUMS = 'INIT_CURRICULUMS'

//アクションクリエーター
export function requestCurriculums(curriculums, 
  access_token,
  student_id,
  selected_box_id,
  selected_agreement_id,
  selected_sub_subject_key,
  selected_subject_id
  ) {
  return {
    type: REQUEST_CURRICULUMS,
    curriculums,
    access_token,
    student_id: student_id,
    selected_box_id,
    selected_agreement_id,
    sub_subject_key:selected_sub_subject_key,
    selected_subject_id
  }
}

export function receiveCurriculums(json) {
  if(json.data.curriculum == null){
    json.data.curriculum = {}
  }
  return {
    type: RECEIVE_CURRICULUMS,
    curriculums: json,
    box_id: json.data.box_id,
    student: json.data.student,
    agreement: json.data.agreement,
    sub_subjects: json.data.sub_subjects,
    curriculum: json.data.curriculum,
    learnings: json.data.learnings,
    selected_sub_subject_key: json.data.learnings.units[0].sub_subject_key,
    selected_sub_subject_name: json.data.learnings.units[0].sub_subject_name,
    isFetchedCurriculums: true
  }
}

export function changeSubSubject(key, name) {
  return {
    type: CHANGE_SUBSUBJECTS,
    selected_sub_subject_key: key,
    selected_sub_subject_name: name
  }
}

export function setCheckedSubUnits(checkedSubUnits) {
  return {
    type: CHANGE_CHECKEDSUBUNITS,
    checkedSubUnits: checkedSubUnits
  }
}

export function setYoutubeModal(bool, youtubeURL) {
  return {
    type: CHANGE_ISYOUTUBEMODAL,
    isYoutubeModal: bool,
    youtubeURL: youtubeURL
  }
}

export function setResetModal(bool) {
  return {
    type: CHANGE_ISRESETMODAL,
    isResetModal: bool
  }
}

export function setYoutubeURL(youtubeURL) {
  return {
    type: CHANGE_YOUTUBEURL,
    youtubeURL: youtubeURL
  }
}

export function setSettingModal(bool) {
  return {
    type: CHANGE_ISSETTINGMODAL,
    isSettingModal: bool
  }
}

export function setEditCalActive(isCalStartActive, isCalEndActive) {
  return{
    type: CHANGE_EDITCALACIVE,
    isCalStartActive: isCalStartActive,
    isCalEndActive: isCalEndActive
  }
}

export function postCurriculums(
    access_token,
    student_id, 
    agreement_id,
    agreement_dow,
    start_date,
    end_date,
    period_id,
    sub_unit_ids,
    sub_subject_key
  ){
  return {
    type: POST_CURRICULUMS,
    access_token,
    student_id, 
    agreement_id,
    agreement_dow,
    start_date,
    end_date,
    period_id,
    sub_unit_ids,
    sub_subject_key
  }
}

export function postedCurriculums(json) {
  window.location.hash = '/student'
  return {
    type: POSTED_CURRICULUMS,
    json
  }
}

export function putCurriculums(access_token, curriculum_id, start_date, end_date, sub_unit_ids) {
  return {
    type: PUT_CURRICULUMS,
    access_token, curriculum_id, start_date, end_date, sub_unit_ids
  }
}

export function puttedCurriculums(json) {
  window.location.hash = '/student'
  return {
    type: PUTTED_CURRICULUMS,
    json
  }
}

export function changeCurriculumStartDate(start_date) {
  return {
    type: CHANGE_CURRICULUM_START_DATE,
    curEditStartDate: start_date
  }
}

export function changeCurriculumEndDate(end_date) {
  return {
    type: CHANGE_CURRICULUM_END_DATE,
    curEditEndDate: end_date
  }
}

export function receivedNumberOfWeeks(numberOfWeeks) {
  return {
    type: RECIEVED_NUMBEROFWEEKS,
    numberOfWeeks: numberOfWeeks
  }
}

export function setPdfModal(isPdfModal) {
  return {
    type: CHANGE_ISPDFMODAL,
    isPdfModal: isPdfModal
  }
}

export function putLearning(
    learnings,
    setLearnings,
    access_token, 
    learning_id, 
    box_id, 
    status, 
    sent_on, 
    student_id, 
    period_id, 
    sub_unit_id, 
    agreement_id
  ) {
  return {
    type: CHANGE_LEARNINGSTATUS,
    learnings,
    setLearnings,
    access_token,
    learning_id,
    box_id,
    status,
    sent_on,
    student_id,
    period_id,
    sub_unit_id,
    agreement_id
  }
}

export function puttedLearning(json, learnings) {
  learnings.units.map(unit => unit.sub_units.map(sub_unit =>{
    if(sub_unit.sub_unit_id == json.data.sub_unit_id){
      sub_unit.learning_status = json.data.learning_status
      sub_unit.agreement_id = json.data.agreement_id
      sub_unit.box_id = json.data.box_id
      sub_unit.curriculum_id = json.data.curriculum_id
      sub_unit.learning_id = json.data.learning_id
      sub_unit.learning_status = json.data.learning_status
      sub_unit.period_id = json.data.period_id
      sub_unit.reported_at = json.data.reported_at
      sub_unit.sent_on = json.data.sent_on
      sub_unit.student_id = json.data.student_id
      sub_unit.sub_unit_id = json.data.sub_unit_id
    }
    
  }))
  return {
    type: PUTTED_LEARNINGSTATUS,
    learnings: learnings,
    json
  }
}

export function changeIsCalStartActive(bool) {
  return {
    type: CHANGE_ISCALSTARTACTIVE,
    isCalStartActive: bool
  }
}

export function changeIsCalEndActive(bool) {
  return {
    type: CHANGE_ISCALENDACTIVE,
    isCalEndActive: bool
  }
}


export function initIsFetchedCurriculums() {
  return {
    type: INIT_IS_FETCHED_CURRICULUMS,
    isFetchedCurriculums: false
  }
}

export function initCurriculums() {
  return {
    type: INIT_CURRICULUMS
  }
}