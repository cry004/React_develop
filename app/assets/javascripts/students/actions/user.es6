export const UPDATE_NICKNAME = 'UPDATE_NICKNAME'
export const RECEIVE_NICKNAME = 'RECEIVE_NICKNAME'
export const UPDATE_NICKNAME_ERROR = 'UPDATE_NICKNAME_ERROR'
export const UPDATE_NICKNAME_SUCCESS = 'UPDATE_NICKNAME_SUCCESS'
export const UPDATE_AVATAR = 'UPDATE_AVATAR'
export const REQUEST_USER = 'REQUEST_USER'
export const RECEIVE_USER = 'RECEIVE_USER'
export const RECEIVE_FIRST_LOGIN = 'RECEIVE_FIRST_LOGIN'
export const HIDE_SCHOOLBOOK_DIALOGS = 'HIDE_SCHOOLBOOK_DIALOGS'
export const REQUEST_USER_PRIVACY_SETTINGS = 'REQUEST_USER_PRIVACY_SETTINGS'
export const RECEIVE_PRIVATE_FLAG = 'RECEIVE_PRIVATE_FLAG'
export const UPDATE_PRIVATE_FLAG = 'UPDATE_PRIVATE_FLAG'
export const REQUEST_SCHOOLBOOKS = 'REQUEST_SCHOOLBOOKS'
export const RECEIVE_SCHOOLBOOKS = 'RECEIVE_SCHOOLBOOKS'
export const UPDATE_SCHOOLBOOKS_SETTING = 'UPDATE_SCHOOLBOOKS_SETTING'
export const RECEIVE_SCHOOLBOOKS_UPDATE = 'RECEIVE_SCHOOLBOOKS_UPDATE'
export const INIT_USER_ALL = 'INIT_USER_ALL'
export const CHANGE_NOTIFICATION_COUNT = 'CHANGE_NOTIFICATION_COUNT'


export function updateNickname(accessToken = "", nickName = null, avatar = "0", currentPath = "/setting_profile") {
  return {
    type: UPDATE_NICKNAME,
    accessToken: accessToken,
    nickName: nickName,
    avatar: avatar,
    currentPath: currentPath
  }
}

export function receiveNickname(nickName) {
  return {
    type: RECEIVE_NICKNAME,
    nickName: nickName
  }
}

export function updateNicknameError(error = []) {
  return {
    type: UPDATE_NICKNAME_ERROR,
    nickNameError: error
  }
}

export function updateNicknameSuccess(text = "") {
  return {
    type: UPDATE_NICKNAME_SUCCESS,
    nickNameSuccess: text
  }
}

export function updateAvatar(accessToken = "", nickName = "", avatar = "0", nextPath = "/learning_progresses") {
  return {
    type: UPDATE_AVATAR,
    accessToken: accessToken,
    nickName: nickName,
    avatar: avatar,
    nextPath: nextPath
  }
}

export function requestUser(accessToken = "") {
  return {
    type: REQUEST_USER,
    accessToken: accessToken
  }
}

export function changeNotificationsCount(){
  return {
    type: CHANGE_NOTIFICATION_COUNT
  }
}
export function receiveUser(user) {
  return {
    type: RECEIVE_USER,
    availablePoint: user.available_point,
    avatar: user.avatar,
    currentMonthlyPoint: user.current_monthly_point,
    firstLogin: user.first_login,
    nickName: user.nick_name,
    isNewUser: user.is_new_user,
    isInternalMember: user.is_internal_member,
    purchasable: user.purchasable,
    questionPoint: user.question_point,
    school: user.school,
    schoolYear: user.school_year,
    sitCd: user.sit_cd,
    unreadNotificationsCount: user.unread_notifications_count,
    isFetching: false
  }
}

export function hideSchoolbookDialogs(accessToken) {
  return {
    type: HIDE_SCHOOLBOOK_DIALOGS,
    accessToken: accessToken
  }
}

export function receiveFirstLogin(firstLogin) {
  return {
    type: RECEIVE_FIRST_LOGIN,
    firstLogin: firstLogin
  }
}

export function requestPrivacySettings(accessToken = "") {
  return {
    type: REQUEST_USER_PRIVACY_SETTINGS,
    accessToken: accessToken
  }
}

export function receivePrivateFlag(privateFlag) {
  return {
    type: RECEIVE_PRIVATE_FLAG,
    privateFlag: privateFlag
  }
}

export function updatePrivateFlag(accessToken = "", privateFlag = false) {
  return {
    type: UPDATE_PRIVATE_FLAG,
    accessToken: accessToken,
    privateFlag: privateFlag
  }
}

export function requestSchoolbooks(accessToken = "") {
  return {
    type: REQUEST_SCHOOLBOOKS,
    accessToken: accessToken
  }
}

export function receiveSchoolbooks(schoolbooks = []) {
  return {
    type: RECEIVE_SCHOOLBOOKS,
    schoolbooks: schoolbooks
  }
}

export function updateSchoolbooksSetting(accessToken = "", book, selectSubject, bookname) {
  return {
    type: UPDATE_SCHOOLBOOKS_SETTING,
    accessToken: accessToken,
    book: book,
    selectSubject: selectSubject,
    bookname: bookname
  }
}

export function receiveSchoolbooksUpdate(selectSubject, bookname) {
  return {
    type: RECEIVE_SCHOOLBOOKS_UPDATE,
    selectSubject: selectSubject,
    bookname: bookname
  }
}
export function initUserAll() {
  return {
    type: INIT_USER_ALL
  }
}
