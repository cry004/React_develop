export const SHOW_POPUP = 'SHOW_POPUP'
export const HIDE_POPUP = 'HIDE_POPUP'

export function showPopup(popupType, args = {}) {
  return {
    type: SHOW_POPUP,
    popupType: popupType,
    isHidden: false,
    args: args
  }
}
export function hidePopup() {
  return {
    type: HIDE_POPUP,
    popupType: "",
    isHidden: true
  }
}