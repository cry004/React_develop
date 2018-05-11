export const REQUEST_NUMBEROFWEEKS = 'REQUEST_NUMBEROFWEEKS'
export const RECIEVED_NUMBEROFWEEKS = 'RECIEVED_NUMBEROFWEEKS'
export const NOTRECIEVED_NUMBEROFWEEKS = 'NOTRECIEVED_NUMBEROFWEEKS'

export function requestNumberOfWeeks(access_token, start_date, end_date) {
  return {
    type: REQUEST_NUMBEROFWEEKS,
    access_token, start_date, end_date
  }
}

export function receivedNumberOfWeeks(numberOfWeeks) {
  return {
    type: RECIEVED_NUMBEROFWEEKS,
    numberOfWeeks: numberOfWeeks
  }
}

export function notReceivedNumberOfWeeks(error) {
  return {
    type: NOTRECIEVED_NUMBEROFWEEKS,
    error
  }
}