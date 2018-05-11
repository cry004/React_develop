import { INIT_USERAGENT_ALL } from '../actions/useragent.es6'

const userAgent = navigator.userAgent;
const initialState = {
  isAndroid: !!(userAgent.indexOf('Android') > 0),
  isIOS: !!(userAgent.indexOf('iPhone') > 0 || userAgent.indexOf('iPad') > 0 || userAgent.indexOf('iPod') > 0),
  isSP: userAgent.indexOf('iPhone') > 0 || userAgent.indexOf('iPad') > 0 || userAgent.indexOf('iPod') > 0 || userAgent.indexOf('Android') > 0, //fixme: スマホとタブレットが含まれているのでスマホだけにする
  isTablet: (userAgent.indexOf('iPhone') > 0 || userAgent.indexOf('iPad') > 0 || userAgent.indexOf('iPod') > 0 || userAgent.indexOf('Android') > 0) && userAgent.indexOf('Mobile') < 1
}

function useragent(state = initialState, action) {
  switch (action.type) {
    case INIT_USERAGENT_ALL:
      return initialState
    default:
      return state
  }
}

export default useragent