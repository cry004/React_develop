export const REQUEST_WORKBOOKS = 'REQUEST_WORKBOOKS'
export const RECEIVE_WORKBOOKS = 'RECEIVE_WORKBOOKS'

export function requestWorkbooks(accessToken) {
  return {
    type: REQUEST_WORKBOOKS,
    accessToken: accessToken
  }
}

export function receiveWorkbooks(subjects) {
  return {
    type: RECEIVE_WORKBOOKS,
    subjects: subjects
  }
}