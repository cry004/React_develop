export const REQUEST_PREFECTURES = 'REQUEST_PREFECTURES'
export const SELECTED_PREFECTURE = 'SELECTED_PREFECTURE'
export const RECEIVE_PREFECTURES = 'RECEIVE_PREFECTURES'
export const NOTRECEIVE_PREFECTURES = 'NOTRECEIVE_PREFECTURES'

export function requestPrefectures(access_token, prefecture) {
  return {
    type: REQUEST_PREFECTURES,
    access_token:access_token, 
    prefecture:prefecture
  }
}

export function selectedPrefecture(value) {
  return {
    type: SELECTED_PREFECTURE,
    selectedPrefecture: value
  }
}

export function receivePrefectures(json) {
  return {
    type: RECEIVE_PREFECTURES,
    prefectures: json.data
  }
}

export function notReceivePrefectures(message) {
  console.log('都道府県を取得できませんでした。')
  return {
    type: NOTRECEIVE_PREFECTURES,
    message
  }
}