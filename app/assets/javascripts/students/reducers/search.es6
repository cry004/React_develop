import { UPDATE_SEARCH_INPUT,
  UPDATE_SEARCH_KEYWORD,
  UPDATE_SEARCH_GRADE,
  REQUEST_SEARCH_WORDS,
  RECEIVE_SEARCH_WORDS,
  RECEIVE_VIDEO_TAGS,
  RECEIVE_SEARCH_VIDEOS,
  RECEIVE_SEARCH_UNITS } from '../actions/search.es6'

const initialState = {
  input: "",
  tags: [],
  words: [],
  unitsCount: 0,
  units: [],
  videosCount: 0,
  videos: [],
  keyword: "",
  grade: "",
  unitVideos: [],
  isFetching: false
}

function search(state = initialState, action) {
  switch (action.type) {
    case UPDATE_SEARCH_INPUT:
      return Object.assign({}, state, {
        input: action.input
      })
    case UPDATE_SEARCH_KEYWORD:
      return Object.assign({}, state, {
        keyword: action.keyword
      })
    case REQUEST_SEARCH_WORDS:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_SEARCH_WORDS:
      return Object.assign({}, state, {
        words: action.words,
        isFetching: action.isFetching
      })
    case UPDATE_SEARCH_GRADE:
      return Object.assign({}, state, {
        grade: action.grade
      })
    case RECEIVE_VIDEO_TAGS:
      return Object.assign({}, state, {
        tags: action.tags
      })
    case RECEIVE_SEARCH_VIDEOS:
      return Object.assign({}, state, {
        unitsCount: action.unitsCount,
        units: action.units,
        videosCount: action.videosCount,
        videos: action.videos
      })
    case RECEIVE_SEARCH_UNITS:
      return Object.assign({}, state, {
        unitVideos: action.unitVideos,
      })
    default:
      return state
  }
}

export default search