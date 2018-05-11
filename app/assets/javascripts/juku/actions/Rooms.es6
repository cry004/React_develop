export const REQUEST_ROOMS = 'REQUEST_ROOMS'
export const RECEIVE_ROOMS = 'RECEIVE_ROOMS'
export const SELECTED_ROOM = 'SELECTED_ROOM'
export const CHANGE_ISAUTOROOMSFETCH = 'CHANGE_ISAUTOROOMSFETCH'
export const CHANGE_ERROR_MESSAGE_FLAG = 'CHANGE_ERROR_MESSAGE_FLAG'
export const INIT_ROOM = 'INIT_ROOM'

export function requestRooms(rooms, access_token, prefecture) {
  return {
    type: REQUEST_ROOMS,
    rooms,
    access_token,
    prefecture,
    isFetchedRooms: false
  }
}

export function selectedRoom(room_id, room_name) {
  return {
    type: SELECTED_ROOM,
    selectedRoom: room_id,
    selectedRoomName: room_name
  }
}

export function receiveRooms(json) {
  return {
    type: RECEIVE_ROOMS,
    rooms: json,
    isAutoRoomsFetch: false,
    isFetchedRooms: true
  }
}

export function setIsAutoRoomsFetch(isAutoRoomsFetch) {
  return {
    type: CHANGE_ISAUTOROOMSFETCH,
    isAutoRoomsFetch: isAutoRoomsFetch
  }
}

export function setErrorMessageFlag(errorMessageFlag) {
  return {
    type: CHANGE_ERROR_MESSAGE_FLAG,
    error_messageFlag: errorMessageFlag
  }
}

export function initRoom() {
  return {
    type: INIT_ROOM
  }
}