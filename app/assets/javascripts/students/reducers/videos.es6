import { 
  REQUEST_VIDEOS,
  RECEIVE_VIDEOS,
  UPDATE_CURRENT_COURCE,
  FILTERED_VIDEOS_UNITS,
  UPDATE_VIDEOS_CURRENT_UNIT } from '../actions/videos.es6'

const initialState = {
  completedVideosCount: 0,
  totalVideosCount: 0,
  schoolbookName: "",
  title: {
    schoolName: "",
    subjectName: "",
    subjectType: "",
    subjectDetailName: ""
  },
  videosSuggest: {
    type: "end",
    videos: []
  },
  units: [],
  filteredUnits: [],
  year: "c1",
  subject: "english_regular",
  currentUnitIndex: null,
  currentSubject: "",
  isFetching: false
}

function videos(state = initialState, action) {
  switch (action.type) {
    case REQUEST_VIDEOS:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_VIDEOS:
      return Object.assign({}, state, {
        unitsCount: action.unitsCount,
        completedVideosCount: action.completedVideosCount,
        totalVideosCount: action.totalVideosCount,
        schoolbookName: action.schoolbookName,
        title: action.title,
        videosSuggest: action.videosSuggest,
        units: action.units,
        currentSubject: action.currentSubject,
        completedTrophiesCount: action.completedTrophiesCount,
        totalTrophiesCount: action.totalTrophiesCount,
        isFetching: action.isFetching
      })
    case FILTERED_VIDEOS_UNITS:
      return Object.assign({}, state, {
        filteredUnits: action.filteredUnits
      })
    case UPDATE_CURRENT_COURCE:
      return Object.assign({}, state, {
        year: action.year,
        subject: action.subject
      })
    case UPDATE_VIDEOS_CURRENT_UNIT:
      return Object.assign({}, state, {
        currentUnitIndex: action.currentUnitIndex
      })
    default:
      return state
  }
}

export default videos