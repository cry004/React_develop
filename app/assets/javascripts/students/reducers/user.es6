import _ from 'lodash'

import { RECEIVE_NICKNAME,
  UPDATE_NICKNAME_ERROR,
  UPDATE_NICKNAME_SUCCESS,
  RECEIVE_USER,
  RECEIVE_FIRST_LOGIN,
  RECEIVE_PRIVATE_FLAG,
  RECEIVE_SCHOOLBOOKS,
  RECEIVE_SCHOOLBOOKS_UPDATE,
  CHANGE_NOTIFICATION_COUNT,
  INIT_USER_ALL } from '../actions/user.es6'

const initialState = {
  availablePoint: 0,
  avatar: 0,
  currentMonthlyPoint: 0,
  firstLogin: false,
  nickName: "",
  purchasable: false,
  questionPoint: 500,
  school: "c",
  //schoolAddress: "",
  //schools: ["教室名1", "教室名2"],
  sitCd: null,
  unreadNotificationsCount: 0,
  nickNameError: [],
  nickNameSuccess: "",
  isInternalMember: false,
  internalMemberType: 'classroom',
  privateFlag: false,
  schoolbooks: {
    schoolyears: []
  },
  isFetching: false
}

function user(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_NICKNAME:
      return Object.assign({}, state, {
        nickName: action.nickName
      })
    case UPDATE_NICKNAME_ERROR:
      return Object.assign({}, state, {
        nickNameError: action.nickNameError
      })
    case UPDATE_NICKNAME_SUCCESS:
      return Object.assign({}, state, {
        nickNameSuccess: action.nickNameSuccess
      })
    case RECEIVE_USER:
      return Object.assign({}, state, {
        accessToken: action.accessToken,
        availablePoint: action.availablePoint,
        avatar: action.avatar,
        currentMonthlyPoint: action.currentMonthlyPoint,
        firstLogin: action.firstLogin,
        nickName: action.nickName,
        isNewUser: action.isNewUser,
        isInternalMember: action.isInternalMember,
        internalMemberType: action.internalMemberType,
        purchasable: action.purchasable,
        questionPoint: action.questionPoint,
        school: action.school,
        schoolYear: action.schoolYear,
        sitCd: action.sitCd,
        unreadNotificationsCount: action.unreadNotificationsCount,
        isFetching: action.isFetching
      })
    case RECEIVE_FIRST_LOGIN:
      return Object.assign({}, state, {
        firstLogin: action.firstLogin
      })
    case RECEIVE_PRIVATE_FLAG:
      return Object.assign({}, state, {
        privateFlag: action.privateFlag
      })
    case RECEIVE_SCHOOLBOOKS:
      return Object.assign({}, state, {
        schoolbooks: action.schoolbooks
      })
    case RECEIVE_SCHOOLBOOKS_UPDATE:
      let newSchoolbooks = Object.assign({}, state.schoolbooks)
      let subjects = newSchoolbooks.schoolyears[0].subjects
      subjects.forEach((subject, i) => {
        if (subject.key === action.selectSubject) {
          subject.schoolbooks.forEach((book, j) => {
            if (book.display_name === action.bookname) {
              subjects[i]['schoolbooks'][j]['selected_flag'] = true
            } else {
              subjects[i]['schoolbooks'][j]['selected_flag'] = false
            }
          })
        }
      })
      return Object.assign({}, state, {
        schoolbooks: newSchoolbooks
      })
    case CHANGE_NOTIFICATION_COUNT:
      let nesunreadCount = state.unreadNotificationsCount - 1
      return Object.assign({}, state, {
        unreadNotificationsCount: nesunreadCount
      })
    case INIT_USER_ALL:
      return Object.assign({}, state, {
        initialState
      })
    default:
      return state
  }
}

export default user
