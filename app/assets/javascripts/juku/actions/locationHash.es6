export const UPDATE_LOCATION_HASH = 'UPDATE_LOCATION_HASH'

export function updateLocationHash(current) {
  return {
    type: UPDATE_LOCATION_HASH,
    current: current
  }
}