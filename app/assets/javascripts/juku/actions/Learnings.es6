export const REQUEST_LEARNINGS = 'REQUEST_LEARNINGS'
export const RECIEVE_LEARNINGS = 'RECIEVE_LEARNINGS'
export const CHANGE_SETLEARNINGS = 'CHANGE_SETLEARNINGS'
export const CHANGE_PDFLISTBTNDISABLE = 'CHANGE_PDFLISTBTNDISABLE'
export const INIT_IS_FETCHED_LEARNINGS = 'INIT_IS_FETCHED_LEARNINGS'
export const INIT_LEARNINGS = 'INIT_LEARNINGS'

export function requestLearnings(access_token, student_id, box_id, subject_id, status, start_date, end_date) {
  return {
    type: REQUEST_LEARNINGS,
    access_token,
    student_id,
    box_id,
    subject_id,
    status,
    start_date,
    end_date
  }
}

export function receiveLearnings(json) {
  return {
    type: RECIEVE_LEARNINGS,
    json,
    setLearnings: json.data.learnings,
    isFetchedLearnings: true
  }
}

export function changePdfListBtnDisable(pdfListBtnDisable) {
  return {
    type: CHANGE_PDFLISTBTNDISABLE,
    pdfListBtnDisable: pdfListBtnDisable
  }
}

export function changeSetLearnings(setLearnings, learning_id, status) {
  setLearnings.map((learing) => {
    learing.sub_units.map((sub_unit) => {
      if(sub_unit.learning_id == learning_id) {
        sub_unit.learning_status = status
      }
    })
  })
  return {
    type: CHANGE_SETLEARNINGS,
    setLearnings: setLearnings
  }
}

export function initIsFetchedLearnings() {
  return {
    type: INIT_IS_FETCHED_LEARNINGS,
    isFetchedLearnings: false
  }
}

export function initLearnings() {
  return {
    type: INIT_LEARNINGS
  }
}