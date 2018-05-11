import _ from 'lodash'

import { 
  REQUEST_NEWS,
  UPDATE_CURRENT_NEWS,
  RECEIVE_NEWS,
  CURRENT_NEWS_ID,
  INIT_NEWS,
  REQUEST_NEWS_DETAIL,
  RECEIVE_NEWS_DETAIL,
  RECEIVE_READ_NEWS,
  INIT_NEWS_ALL } from '../actions/news.es6'

const initialState = {
  currentId: null,
  news: [],
  currentNews: {
    content: "",
    date: "",
    id: "",
    imageUrl: "",
    title: ""
  },
  isFetching: false,
  isListFetching: false
}

function news(state = initialState, action) {
  switch (action.type) {
    case REQUEST_NEWS:
      return Object.assign({}, state, {
        isListFetching: action.isListFetching
      })
    case RECEIVE_NEWS:
      return Object.assign({}, state, {
        news: state.news.concat(action.news),
        isListFetching: action.isListFetching
      })
    case CURRENT_NEWS_ID:
      return Object.assign({}, state, {
        currentId: action.currentId
      })
    case INIT_NEWS:
      return Object.assign({}, state, {
        news: action.news
      })
    case REQUEST_NEWS_DETAIL:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })      
    case RECEIVE_NEWS_DETAIL:
      return Object.assign({}, state, {
        currentNews: action.currentNews,
        isFetching: action.isFetching
      })
    case RECEIVE_READ_NEWS:
      let news = _.map(state.news, (news, index)  => {
        if (news.id === action.id) {
          let info = news
          info.unread = false
          return info
        } else {
          return news
        }
      })
      return Object.assign({}, state, {
        news: news
      })
    case INIT_NEWS_ALL:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default news