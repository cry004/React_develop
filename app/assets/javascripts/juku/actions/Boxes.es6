export const REQUEST_BOXES = 'REQUEST_BOXES'
export const RECEIVE_BOXES = 'RECEIVE_BOXES'
export const CHANGE_SCHEDULE_TYPE = 'CHANGE_SCHEDULE_TYPE'
export const CHANGE_ISCALACTIVE = 'CHANGE_ISCALACTIVE'
export const SELECTED_BOX = 'SELECTED_BOX'
export const CHANGE_BOX_ID = 'CHANGE_BOX_ID'
export const CHANGE_SELECTED_AGREEMENT_ID = 'CHANGE_SELECTED_AGREEMENT_ID'
export const INIT_IS_FETCHED_BOX = 'INIT_IS_FETCHED_BOX'
export const INIT_BOX_STATE = 'INIT_BOX_STATE'

export function requestBoxes(boxes, access_token, classroom_id, start_date, end_date) {
  return {
    type: REQUEST_BOXES,
    boxes,
    access_token,
    classroom_id,
    start_date: start_date,
    end_date: end_date
  }
}

export function receiveBoxes(json) {
  return {
    type: RECEIVE_BOXES,
    boxes: json,
    items: json.data.items,
    periods: json.data.periods,
    isFetchedBox: true
  }
}

export function selectedBox(
    student_id,
    student_name,
    subject_id,
    schoolyear_key,
    box_id,
    agreement_id,
    period_id,
    date
  ) {
  return {
    type: SELECTED_BOX,
    selected_student_id: student_id,
    selected_subject_id: subject_id,
    selected_schoolyear_key: schoolyear_key,
    selected_box_id: box_id,
    selected_agreement_id: agreement_id,
    selected_period_id: period_id,
    selected_date: date,
    selected_student_name: student_name
  }
}

export function changeSeletedBoxID(box_id) {
  return {
    type: CHANGE_BOX_ID,
    selected_box_id: box_id
  }
}

export function changeIsCalActive(bool) {
  return {
    type: CHANGE_ISCALACTIVE,
    isCalActive: bool
  }
}

export function changeScheduleType(schedule_type) {
  return {
    type: CHANGE_SCHEDULE_TYPE,
    schedule_type: schedule_type
  }
}

export function changeSelectedAgreementID(selected_agreement_id) {
  return {
    type: CHANGE_SELECTED_AGREEMENT_ID,
    selected_agreement_id: selected_agreement_id
  }
}

export function initIsFetchedBox() {
  return {
    type: INIT_IS_FETCHED_BOX,
    isFetchedBox: false
  }
}

export function initBoxState() {
  return {
    type: INIT_BOX_STATE,
  }
}