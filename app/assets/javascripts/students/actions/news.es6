export const REQUEST_NEWS = 'REQUEST_NEWS'
export const REQUEST_NEWS_DETAIL = 'REQUEST_NEWS_DETAIL'
export const RECEIVE_NEWS_DETAIL = 'RECEIVE_NEWS_DETAIL'
export const RECEIVE_NEWS = 'RECEIVE_NEWS'
export const CURRENT_NEWS_ID = 'CURRENT_NEWS_ID'
export const READ_NEWS = 'READ_NEWS'
export const RECEIVE_READ_NEWS = 'RECEIVE_READ_NEWS'
export const INIT_NEWS_ALL = 'INIT_NEWS_ALL'
export const INIT_NEWS = 'INIT_NEWS'

export function requestNews(accessToken = "", maxId = null, perPage = 20, isUpdateCurrentId = false) {
  return {
    type: REQUEST_NEWS,
    accessToken: accessToken,
    maxId: maxId,
    perPage: perPage,
    isUpdateCurrentId: isUpdateCurrentId,
    isListFetching: true
  }
}
export function receiveNews(news = []) {
  return {
    type: RECEIVE_NEWS,
    news: news,
    isListFetching: false
  }
}

export function requestNewsDetail(accessToken = "", id = 1, isUpdateCurrentId = false) {
  return {
    type: REQUEST_NEWS_DETAIL,
    accessToken: accessToken,
    id: id,
    isUpdateCurrentId: isUpdateCurrentId,
    isFetching: true,
  }
}
export function receiveNewsDetail(data) {
  return {
    type: RECEIVE_NEWS_DETAIL,
    currentNews: {
      content: data.content,
      date: data.date,
      id: data.id,
      imageUrl: data.image_url,
      title: data.title
    },
    isFetching: false
  }
}

export function currentNewsId(currentId = 1) {
  return {
    type: CURRENT_NEWS_ID,
    currentId: currentId
  }
}

export function readNews(accessToken = "", id = 1) {
  return {
    type: READ_NEWS,
    accessToken: accessToken,
    id: id
  }
}

export function receiveReadNews(id = 1) {
  return {
    type: RECEIVE_READ_NEWS,
    id: id
  }
}

export function initNews() {
  return {
    type: INIT_NEWS,
    news: []
  }
}

export function initNewsAll() {
  return {
    type: INIT_NEWS_ALL
  }
}