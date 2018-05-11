export const UPDATE_CURRENT_PAGE = 'UPDATE_CURRENT_PAGE'
export const IS_LAST_PAGE = 'IS_LAST_PAGE'
export const INIT_PAGER = 'INIT_PAGER'

export function updateCurrentPage(currentPage) {
  return {
    type: UPDATE_CURRENT_PAGE,
    currentPage: currentPage
  }
}

export function isLastPage(isLastPage) {
  return {
    type: IS_LAST_PAGE,
    isLastPage: isLastPage
  }
}

export function initPager() {
  return {
    type: INIT_PAGER
  }
}