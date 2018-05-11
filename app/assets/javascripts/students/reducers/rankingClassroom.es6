import { 
  REQUEST_RANKINGS_CLASSROOM,
  UPDATE_CURRENT_RANKING_CLASSROOM_TERM,
  RECEIVE_RANKINGS_CLASSROOM,
  RECEIVE_RANKINGS_CLASSROOMS,
  INIT_RANKINGS_CLASSROOM,
  UPDATE_CURRENT_RANKING_CLASSROOM_TAB } from '../actions/rankingsClassroom.es6'

const initialState = {
  currentTerm: 'last_7_days',
  currentTab: {
    classroomType: 'classroom',
    regionType: 'national'
  },
  term: {
    start: '2016/1/1',
    end: '2016/2/2'
  },
  classroom: {
    id: 0,
    color: 14,
    name: "",
    type: "classroom",
    prefecture_name: "東京都"
  },
  rankingMonth: 1,
  learningTime: {
    hours: 0,
    minutes: 0
  },
  rankingDate: {
    start: "2017/01/01",
    end: "2017/01/01"
  },
  currentClassroomRankings: {
    prefecture: 1,
    national: 1
  },
  rankingChanges: {
    prefecture: 0,
    national: 0
  },
  rankings: [],
  isFetching: false
}

function rankingClassroom(state = initialState, action) {
  switch (action.type) {
    case REQUEST_RANKINGS_CLASSROOM:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_RANKINGS_CLASSROOM:
      return Object.assign({}, state, {
        rankings: action.rankings,
        isFetching: action.isFetching
      })
    case RECEIVE_RANKINGS_CLASSROOMS:
      return Object.assign({}, state, {
        classroom: action.classroom,
        rankingMonth: action.rankingMonth,
        learningTime: action.learningTime,
        rankingDate: action.rankingDate,
        currentClassroomRankings: action.currentClassroomRankings,
        rankingChanges: action.rankingChanges
      })
    case UPDATE_CURRENT_RANKING_CLASSROOM_TERM:
      return Object.assign({}, state, {
        currentTerm: action.currentTerm
      })
    case UPDATE_CURRENT_RANKING_CLASSROOM_TAB:
      return Object.assign({}, state, {
        currentTab: action.currentTab
      })
    case INIT_RANKINGS_CLASSROOM:
      return initialState
    default:
      return state
  }
}

export default rankingClassroom