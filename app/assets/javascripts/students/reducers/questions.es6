import { REQUEST_QUESTIONS,
  RECEIVE_QUESTIONS,
  DELETE_QUESTION,
  DELETED_QUESTION,
  INIT_QUESTIONS } from '../actions/questions.es6'
import _ from 'lodash'
const initialState = {
  questions: [],
  isFetching: false
}

function questions(state = initialState, action) {
  switch (action.type) {
    case REQUEST_QUESTIONS:
      return Object.assign({}, state, {
        isFetching: action.isFetching
      })
    case RECEIVE_QUESTIONS:
      return Object.assign({}, state, {
        //読み込み済のquestionsに今回取得したページのquestionsを結合
        questions: state.questions.concat(action.questions),
        isFetching: action.isFetching
      })
    case DELETE_QUESTION:
      return Object.assign({}, state, {
        deleteId: action.deleteId
      })
    case DELETED_QUESTION:
      const questions = _.remove(state.questions, (question) => {
          return question.id !== action.deletedId
        }
      )
      return Object.assign({}, state, {
        questions: questions
      })
    case INIT_QUESTIONS:
      return Object.assign({}, state, {
        questions: action.questions
      })
    default:
      return state
  }
}

export default questions