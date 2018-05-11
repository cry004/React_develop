export const REQUEST_COURSES = 'REQUEST_COURSES'
export const RECEIVE_COURSES = 'RECEIVE_COURSES'

export function requestCourses(accessToken = "") {
  return {
    type: REQUEST_COURSES,
    accessToken: accessToken,
  }
}

export function receiveCourses(courses) {
  return {
    type: RECEIVE_COURSES,
    courses: courses,
  }
}