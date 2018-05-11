export const REQUEST_STUDENTS = 'REQUEST_STUDENTS'
export const RECEIVE_STUDENTS = 'RECEIVE_STUDENTS'
export const NOTRECEIVE_STUDENTS = 'NOTRECEIVE_STUDENTS'
export const SET_SEARCHTEXT = 'SET_SEARCHTEXT'
export const SEARCH_STUDENTS = 'SEARCH_STUDENTS'
export const INIT_STUDENTS = 'INIT_STUDENTS'

export function requestStudents(classroom_id, access_token) {
  return {
    type: REQUEST_STUDENTS,
    classroom_id: classroom_id,
    access_token: access_token,
    isFetchedStudents: false
  }
}

export function receiveStudents(json) {
  return {
    type: RECEIVE_STUDENTS,
    students: json.data.students,
    searched_students: json.data.students,
    periods: json.data.periods,
    isFetchedStudents: true
  }
}

export function notReceiveStudents(message) {
  console.log('生徒一覧が取得できませんでした。')
  window.location.hash = '/room'
  return {
    type: NOTRECEIVE_STUDENTS,
    message: message
  }
}

export function searchStudents(students) {
  return {
    type: SEARCH_STUDENTS,
    searched_students: students
  }
}

export function setSearchText(text) {
  return {
    type: SET_SEARCHTEXT,
    search_text: text
  }
}

export function initStudents() {
  return {
    type: INIT_STUDENTS
  }
}