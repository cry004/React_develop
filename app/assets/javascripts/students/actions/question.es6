export const UPDATE_CURRENT_QUESTION = 'UPDATE_CURRENT_QUESTION'
export const REQUEST_QUESTION = 'REQUEST_QUESTION'
export const RECEIVE_QUESTION = 'RECEIVE_QUESTION'
export const UPDATE_QUESTION_READ = 'UPDATE_QUESTION_READ'
export const RESOLVE_QUESTION = 'RESOLVE_QUESTION'
export const UNRESOLVE_QUESTION = 'UNRESOLVE_QUESTION'
export const UPDATE_RESOLVABLE = 'UPDATE_RESOLVABLE'
export const UPDATE_QUESTION_STATE = 'UPDATE_QUESTION_STATE'
export const INIT_QUESTION = 'INIT_QUESTION'

export function updateCurrentQuestion(id) {
  return {
    type: UPDATE_CURRENT_QUESTION,
    id: id
  }
}

export function requestQuestion(accessToken, id) {
  return {
    type: REQUEST_QUESTION,
    accessToken: accessToken,
    id: id,
    isFetching: true
  }
}

export function receiveQuestion(question) {
  return {
    type: RECEIVE_QUESTION,
    posts: question.posts,
    resolvable: question.resolvable,
    state: question.state,
    subject: question.subject,
    unread: question.unread,
    isFetching: false
  }
}


export function updateQuestionRead(accessToken = "", id) {
  return {
    type: UPDATE_QUESTION_READ,
    accessToken: accessToken,
    id: id
  }
}

export function resolveQuestion(accessToken = "", id) {
  return {
    type: RESOLVE_QUESTION,
    accessToken: accessToken,
    id: id
  }
}

export function unresolveQuestion(accessToken = "", id) {
  return {
    type: UNRESOLVE_QUESTION,
    accessToken: accessToken,
    id: id
  }
}

export function updateQuestionState(state = {}) {
  return {
    type: UPDATE_QUESTION_STATE,
    state: state
  }
}

export function initQuestion() {
  return {
    type: INIT_QUESTION
  }
}



