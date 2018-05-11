export const IS_SHOW_LOADING = 'IS_SHOW_LOADING'

export function isShowLoading(loading = false) {
  return {
    type: IS_SHOW_LOADING,
    isShowLoading: loading
  }
}