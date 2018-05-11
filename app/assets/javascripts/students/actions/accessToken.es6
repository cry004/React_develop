export const SET_ACCESSTOKEN = 'SET_ACCESSTOKEN'
export const INIT_ACCESS_TOKEN = 'INIT_ACCESS_TOKEN'

export function setAccessToken(accessToken) {
  return {
    type: SET_ACCESSTOKEN,
    accessToken: accessToken,
    isAccessToken: true
  }
}

export function initAccessToken() {
  return {
    type: INIT_ACCESS_TOKEN,
    isAccessToken: false
  }
}