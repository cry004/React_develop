import { REQUEST_PREFECTURES, RECEIVE_PREFECTURES, SELECTED_PREFECTURE } from '../actions/Prefectures.es6'

const initialState = {
  isPrefecturesFetch: false,
  prefectures: [{name:'test'}, {name:'test2'}],
  selectedPrefecture: ''
}

function requestPrefectures(state = initialState, action) {
  switch (action.type) {
    case REQUEST_PREFECTURES:
      return Object.assign({}, state, {
        isPrefecturesFetch: true
      })
    case RECEIVE_PREFECTURES:
      return Object.assign({}, state, {
        prefectures: action.prefectures,
        isPrefecturesFetch: false
      })
    case SELECTED_PREFECTURE:
      return Object.assign({}, state, {
        selectedPrefecture: action.selectedPrefecture
      })
    default:
      return state
  }
}

export default requestPrefectures