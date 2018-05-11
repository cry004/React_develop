export const UPDATE_SEARCH_INPUT = 'UPDATE_SEARCH_INPUT'
export const UPDATE_SEARCH_KEYWORD = 'UPDATE_SEARCH_KEYWORD'
export const UPDATE_SEARCH_GRADE = 'UPDATE_SEARCH_GRADE'
export const REQUEST_SEARCH_WORDS = 'REQUEST_SEARCH_WORDS'
export const RECEIVE_SEARCH_WORDS = 'RECEIVE_SEARCH_WORDS'
export const POST_SEARCHED_WORD = 'POST_SEARCHED_WORD'
export const REQUEST_VIDEO_TAGS = 'REQUEST_VIDEO_TAGS'
export const RECEIVE_VIDEO_TAGS = 'RECEIVE_VIDEO_TAGS'
export const REQUEST_SEARCH_VIDEOS = 'REQUEST_SEARCH_VIDEOS'
export const RECEIVE_SEARCH_VIDEOS = 'RECEIVE_SEARCH_VIDEOS'
export const REQUEST_SEARCH_UNITS = 'REQUEST_SEARCH_UNITS'
export const RECEIVE_SEARCH_UNITS = 'RECEIVE_SEARCH_UNITS'

export function updateSearchInput(input) {
  return {
    type: UPDATE_SEARCH_INPUT,
    input: input
  }
}

export function updateSearchKeyword(keyword) {
  return {
    type: UPDATE_SEARCH_KEYWORD,
    keyword: keyword
  }
}

export function updateSearchGrade(grade) {
  return {
    type: UPDATE_SEARCH_GRADE,
    grade: grade
  }
}

export function requestSearchWords(accessToken = "") {
  return {
    type: REQUEST_SEARCH_WORDS,
    accessToken: accessToken,
    isFetching: true
  }
}
export function receiveSearchWords(words = []) {
  return {
    type: RECEIVE_SEARCH_WORDS,
    words: words,
    isFetching: false
  }
}

export function requestSearchVideos(accessToken = "", keyword = "", page = 1,  grade="") {
  return {
    type: REQUEST_SEARCH_VIDEOS,
    accessToken: accessToken,
    page: page,
    perPage: 20,
    keyword: keyword,
    grade: grade
  }
}

export function requestSearchUnits(accessToken = "", title = "", titleDescription = "", schoolbookId) {
  return {
    type: REQUEST_SEARCH_UNITS,
    accessToken: accessToken,
    title: title,
    titleDescription: titleDescription,
    schoolbookId: schoolbookId
  }
}

export function receiveSearchUnits(unitVideos) {
  return {
    type: RECEIVE_SEARCH_UNITS,
    unitVideos: unitVideos
  }
}

export function receiveSearchVideos(unitsCount = 0, units = [], videosCount = 0, videos = []) {
  return {
    type: RECEIVE_SEARCH_VIDEOS,
    unitsCount: unitsCount,
    units: units,
    videosCount: videosCount,
    videos: videos
  }
}

export function postSearchedWord(accessToken = [], searchedWord) {
  return {
    type: POST_SEARCHED_WORD,
    accessToken: accessToken,
    searchedWord: searchedWord
  }
}

export function requestVideoTags(accessToken = "") {
  return {
    type: REQUEST_VIDEO_TAGS,
    accessToken: accessToken
  }
}

export function receiveVideoTags(tags = []) {
  return {
    type: RECEIVE_VIDEO_TAGS,
    tags: tags
  }
}

