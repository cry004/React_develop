export const CHANGE_START_DATE = 'CHANGE_START_DATE'
export const CHANGE_END_DATE = 'CHANGE_END_DATE'
export const CHANGE_ISCALSTARTACTIVE = 'CHANGE_ISCALSTARTACTIVE'
export const CHANGE_ISCALENDACTIVE = 'CHANGE_ISCALENDACTIVE'
export const CHANGE_CALACIVE = 'CHANGE_CALACIVE'
export const CHANGE_ISCALACTIVE = 'CHANGE_ISCALACTIVE'
export const REQUEST_SUBJECTS = 'REQUEST_SUBJECTS'
export const RECEIVE_SUBJECTS = 'RECEIVE_SUBJECTS'
export const NOTRECEIVE_SUBJECTS = 'NOTRECEIVE_SUBJECTS'
export const CHANGE_CHECKEDSUBUNITS = 'CHANGE_CHECKEDSUBUNITS'
export const INIT_SIMULATOR = 'INIT_SIMULATOR'

export function requestSubjects(access_token, subject_val) {
  return {
    type: REQUEST_SUBJECTS,
    access_token,
    subject_val,
    isFetchedSubjects: false
  }
}

export function receiveSubjects(json) {
  return {
    type: RECEIVE_SUBJECTS,
    sub_subjects: json.data.sub_subjects,
    units: json.data.units,
    isFetchedSubjects: true
  }
}

export function notReceiveSubjects(message) {
  console.log('科目一覧が取得できませんでした。')
  return {
    type: NOTRECEIVE_SUBJECTS,
    message
  }
}

export function changeStartDate(start_date) {
  return {
    type: CHANGE_START_DATE,
    start_date: start_date
  }
}

export function changeEndDate(end_date){
  return {
    type: CHANGE_END_DATE,
    end_date: end_date
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

export function changeCalActive(isCalStartActive, isCalEndActive){
  return{
    type: CHANGE_CALACIVE,
    isCalStartActive: isCalStartActive,
    isCalEndActive: isCalEndActive
  }
}

export function changeIsCalActive(bool) {
  return {
    type: CHANGE_ISCALACTIVE,
    isCalActive: bool
  }
}

export function setCheckedSubUnits(checkedSubUnits){
  return {
    type: CHANGE_CHECKEDSUBUNITS,
    checkedSubUnits: checkedSubUnits
  }
}

export function initSimulator() {
  return {
    type: INIT_SIMULATOR
  }
}