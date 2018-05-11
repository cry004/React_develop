export const REQUEST_TEACHER_RECOMMENDS = 'REQUEST_TEACHER_RECOMMENDS'
export const RECEIVE_TEACHER_RECOMMENDS = 'RECEIVE_TEACHER_RECOMMENDS'
export const REQUEST_TEACHER_DETAIL = 'REQUEST_TEACHER_DETAIL'
export const RECEIVE_TEACHER_DETAIL = 'RECEIVE_TEACHER_DETAIL'
export const UPDATE_CURRENT_TEACHER_ID = 'UPDATE_CURRENT_TEACHER_ID'
export const READ_TEACHER_DETAIL = 'READ_TEACHER_DETAIL'
export const RECEIVE_READ_TEACHER_DETAIL = 'RECEIVE_READ_TEACHER_DETAIL'
export const INIT_TEACHER_RECOMMENDS = 'INIT_TEACHER_RECOMMENDS'
export const INIT_TEACHER_ALL = 'INIT_TEACHER_ALL'


export function requestTeacherRecommends(accessToken = "", page = 1, perPage = 20, isUpdateCurrentId = false) {
  return {
    type: REQUEST_TEACHER_RECOMMENDS,
    accessToken: accessToken,
    page: page,
    perPage: perPage,
    isUpdateCurrentId: isUpdateCurrentId,
    isFetching: true
  }
}

export function receiveTeacherRecommends(recommendations = []) {
  return {
    type: RECEIVE_TEACHER_RECOMMENDS,
    recommendations: recommendations,
    isFetching: false
  }
}

export function requestTeacherDetail(accessToken, id) {
  return {
    type: REQUEST_TEACHER_DETAIL,
    accessToken: accessToken,
    id: id
  }
}

export function receiveTeacherDetail(data) {
  return {
    type: RECEIVE_TEACHER_DETAIL,
    currentRecommend: {
      date: data.date,
      message: data.message,
      videos: data.recommended_videos,
      teacherName: data.teacher_name
    }
  }
}

export function updateCurrentTeacherId(id) {
  return {
    type: UPDATE_CURRENT_TEACHER_ID,
    currentId: id
  }
}

export function initTeacherRecommends() {
  return {
    type: INIT_TEACHER_RECOMMENDS
  }
}


export function initTeacherAll() {
  return {
    type: INIT_TEACHER_ALL
  }
}


export function readTeacherDetail(accessToken = "", id = 1) {
  return {
    type: READ_TEACHER_DETAIL,
    accessToken: accessToken,
    id: id
  }
}

export function receiveReadTeacherDetail(id = 1) {
  return {
    type: RECEIVE_READ_TEACHER_DETAIL,
    id: id
  }
}