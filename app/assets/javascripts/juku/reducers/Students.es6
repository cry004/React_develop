import { REQUEST_STUDENTS, RECEIVE_STUDENTS, NOTRECEIVE_STUDENTS, SET_SEARCHTEXT, SEARCH_STUDENTS, INIT_STUDENTS } from '../actions/Students.es6'

const initialState = {
  search_text: '',
  students: [],
  searched_students: [],
  periods: [],
  isFetchedStudents: false
}

function requestStudents(state = initialState, action) {
  switch (action.type) {
    case REQUEST_STUDENTS:
      return Object.assign({}, state, {
        classroom_id: action.classroom_id,
        access_token: action.access_token,
        isFetchedStudents: action.isFetchedStudents
      })
    case RECEIVE_STUDENTS:
      return Object.assign({}, state, {
        students: action.students,
        searched_students: action.searched_students,
        periods: action.periods,
        isFetchedStudents: action.isFetchedStudents
      })
    case NOTRECEIVE_STUDENTS:
      return Object.assign({}, state, {
        message: action.message
      })
    case SET_SEARCHTEXT:
      return Object.assign({}, state, {
        search_text: action.search_text
      })
    case SEARCH_STUDENTS:
      return Object.assign({}, state, {
        searched_students: action.searched_students
      })
    case INIT_STUDENTS:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestStudents