import { 
  REQUEST_RANKINGS_PERSONAL,
  UPDATE_CURRENT_RANKING_TERM,
  RECEIVE_RANKINGS_PERSONAL,
  RECEIVE_RANKINGS_PERSONALS,
  INIT_RANKINGS,
  UPDATE_CURRENT_RANKING_TAB } from '../actions/rankings.es6'

const initialState = {
  currentTerm: 'last_7_days',
  currentTab: 'national',
  term: {
    start: '2016/1/1',
    end: '2016/2/2'
  },
  student: {
    avatar: 0,
    nick_name: "名無し",
    full_name: "名無し",
    school_year: "小学１年生",
    school_address: "",
    level: 1
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
  currentStudentRankings: {
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

function ranking(state = initialState, action) {
  switch (action.type) {
    case REQUEST_RANKINGS_PERSONAL:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })   
    case UPDATE_CURRENT_RANKING_TERM:
      return Object.assign({}, state, {
        currentTerm: action.currentTerm
      })
    case UPDATE_CURRENT_RANKING_TAB:
      return Object.assign({}, state, {
        currentTab: action.currentTab
      })
    case RECEIVE_RANKINGS_PERSONAL:
      return Object.assign({}, state, {
        rankings: action.rankings,
        isFetching: action.isFetching
      })
    case RECEIVE_RANKINGS_PERSONALS:
      return Object.assign({}, state, {
        student: action.student,
        rankingMonth: action.rankingMonth,
        learningTime: action.learningTime,
        rankingDate: action.rankingDate,
        currentStudentRankings: action.currentStudentRankings,
        rankingChanges: action.rankingChanges
      })
    case INIT_RANKINGS:
      return initialState
    default:
      return state
  }
}

export default ranking