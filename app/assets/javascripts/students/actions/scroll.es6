export const SCROLL_LEFT = 'SCROLL_LEFT'
export const INIT_SCROLL_LEFT = 'INIT_SCROLL_LEFT'

export function updateScrollLeft(left) {
  return {
    type: SCROLL_LEFT,
    left: left
  }
}

export function initScrollLeft() {
  return {
    type: INIT_SCROLL_LEFT
  }
}