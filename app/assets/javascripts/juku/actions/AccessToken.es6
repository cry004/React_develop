export const SET_ACCESSTOKEN = 'SET_ACCESSTOKEN'
export const FROM_TRYPLUS = 'FROM_TRYPLUS'
export const INIT_FROM_TRYPLUS = 'INIT_FROM_TRYPLUS'

export function setAccessToken(token) {
  let access_token = token.replace( /Bearer\+/g , "" )
  return {
    type: SET_ACCESSTOKEN,
    access_token: access_token,
    isAccessToken: true
  }
}

export function isFromTryPlus() {
  return {
    type: FROM_TRYPLUS,
    isFromTryPlus: true
  }
}

export function initFromTryPlus() {
  return {
    type: INIT_FROM_TRYPLUS
  }
}
