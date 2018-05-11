export const REQUEST_LEARNINGREPORTS = 'REQUEST_LEARNINGREPORTS'
export const RECEIVE_LEARNINGREPORTS = 'RECEIVE_LEARNINGREPORTS'
export const NOTRECEIVE_LEARNINGREPORTS = 'NOTRECEIVE_LEARNINGREPORTS'
export const POST_LEARNINGREPORT = 'POST_LEARNINGREPORT'
export const CHANGE_REPORTED_AT = 'CHANGE_REPORTED_AT'
export const INIT_IS_FETCHED_REPORT = 'INIT_IS_FETCHED_REPORT'
export const INIT_REPORT = 'INIT_REPORT'
export const INIT_IS_READY_TO_PRINT = 'INIT_IS_READY_TO_PRINT'

//アクションクリエーター
export function requestLearningReports(
    access_token,
    selected_box_id,
    selected_agreement_id,
    reported_at,
    subject_id
  ) {
  return {
    type: REQUEST_LEARNINGREPORTS,
    access_token,
    selected_box_id,
    selected_agreement_id,
    reported_at,
    subject_id
  }
}

export function receiveLearningReports(json) {
  return {
    type: RECEIVE_LEARNINGREPORTS,
    box_id: json.data.box_id,
    report_date: json.data.report_date,
    student: json.data.student,
    agreement: json.data.agreement,
    curriculums: json.data.curriculums,
    e_navis: json.data.e_navis,
    isFetchedReport: true,
    isReadyToPrint: false
  }
}

export function notReceiveLearningReports(message) {
  console.log('報告書データを取得できませんでした。')
  return {
    type: NOTRECEIVE_LEARNINGREPORTS,
    message
  }
}

export function postLearningReport(access_token, box_id, reported_at, selected_agreement_id, student_id) {
  return {
    type: POST_LEARNINGREPORT,
    access_token, box_id, reported_at: reported_at, selected_agreement_id, student_id,
    isReadyToPrint: true
  }
}

export function changeReportedAt(reported_at) {
  return {
    type: CHANGE_REPORTED_AT,
    reported_at
  }
}

export function initIsFetchedReport() {
  return {
    type: INIT_IS_FETCHED_REPORT,
    isFetchedReport: false
  }
}

export function initisReadyToPrint() {
  return {
    type: INIT_IS_READY_TO_PRINT,
    isReadyToPrint: false
  }
}

export function initReport() {
  return {
    type: INIT_REPORT
  }
}
