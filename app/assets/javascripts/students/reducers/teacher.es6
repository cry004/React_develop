import _ from 'lodash'

import { REQUEST_TEACHER_RECOMMENDS,
  RECEIVE_TEACHER_RECOMMENDS,
  RECEIVE_TEACHER_DETAIL,
  UPDATE_CURRENT_TEACHER_ID,
  RECEIVE_READ_TEACHER_DETAIL,
  INIT_TEACHER_RECOMMENDS,
  INIT_TEACHER_ALL } from '../actions/teacher.es6'

const initialState = {
  recommendations: [],
  isFetching: false,
  currentId: null,
  currentRecommend: {
    data: "",
    message: "",
    videos: [],
    teacherName: ""
  }
}

function teacher(state = initialState, action) {
  switch (action.type) {
    case REQUEST_TEACHER_RECOMMENDS:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })    
    case RECEIVE_TEACHER_RECOMMENDS:
      return Object.assign({}, state, {
        //読み込み済のrecommendationsに今回取得したページのrecommendationsを結合
        recommendations: state.recommendations.concat(action.recommendations),
        //recommendations: [],
        isFetching: action.isFetching
      })
    case RECEIVE_TEACHER_DETAIL:
      return Object.assign({}, state, {
        currentRecommend: action.currentRecommend
      })
    case RECEIVE_READ_TEACHER_DETAIL:
      let recommendations = _.map(state.recommendations, (reconmmend, index)  => {
        if (reconmmend.recommendation_id === action.id) {
          let recommends = reconmmend
          recommends.unread = false
          return recommends
        } else {
          return reconmmend
        }
      })
      return Object.assign({}, state, {
        recommendations: recommendations
      })
    case UPDATE_CURRENT_TEACHER_ID:
      return Object.assign({}, state, {
        currentId: action.currentId
      })
    case INIT_TEACHER_RECOMMENDS:
      return Object.assign({}, state, {
        recommendations: [],
        currentRecommend: {
          data: "",
          message: "",
          videos: [],
          teacherName: ""
        }
      })
    case INIT_TEACHER_ALL:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default teacher