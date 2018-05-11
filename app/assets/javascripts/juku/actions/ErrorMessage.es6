export const ADD_ERROR_MESSAGE = 'ADD_ERROR_MESSAGE'
export const INIT_ERROR_MESSAGE = 'INIT_ERROR_MESSAGE'

export function addErrorMessage(errors) {
  return {
    type: ADD_ERROR_MESSAGE,
    errors: errors
  }
}

export function initErrorMessage(error = []) {
  return {
    type: INIT_ERROR_MESSAGE,
    errors: error
  }
}