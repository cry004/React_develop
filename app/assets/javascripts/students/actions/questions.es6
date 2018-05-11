export const REQUEST_QUESTIONS = 'REQUEST_QUESTIONS'
export const RECEIVE_QUESTIONS = 'RECEIVE_QUESTIONS'
export const DELETE_QUESTION = 'DELETE_QUESTION'
export const DELETED_QUESTION = 'DELETED_QUESTION'
export const INIT_QUESTIONS = 'INIT_QUESTIONS'

export function requestQuestions(accessToken, page) {
  return {
    type: REQUEST_QUESTIONS,
    accessToken: accessToken,
    page: page,
    perPage: 20,
    isFetching: true
  }
}

export function receiveQuestions(questions) {
  return {
    type: RECEIVE_QUESTIONS,
    questions: questions,
    isFetching: false
  }
}

export function deleteQuestion(accessToken, deleteId) {
  return {
    type: DELETE_QUESTION,
    accessToken: accessToken,
    deleteId: deleteId
  }
}

export function deletedQuestion(deletedId) {
  return {
    type: DELETED_QUESTION,
    deletedId: deletedId
  }
}

export function initQuestions() {
  return {
    type: INIT_QUESTIONS,
    questions: []
  }
}