export const REQUEST_LOGIN = 'REQUEST_LOGIN'
export const REQUEST_LOGOUT = 'REQUEST_LOGOUT'
export const LOGIN_ERROR_MESSAGE = 'LOGIN_ERROR_MESSAGE'
export const INIT_LOGIN = 'INIT_LOGIN'


export function requestLogin(id, password) {
  return {
    type: REQUEST_LOGIN,
    id: id,
    password: password,
    isSending: true
  }
}

export function requestLogout(accessToken) {
  return {
    type: REQUEST_LOGOUT,
    accessToken: accessToken,
  }
}

export function loginErrorMessage(errorMessage) {
  return {
    type: LOGIN_ERROR_MESSAGE,
    errorMessage: errorMessage,
    isSending: false
  }
}

export function initLogin() {
  return {
    type: INIT_LOGIN
  }
}