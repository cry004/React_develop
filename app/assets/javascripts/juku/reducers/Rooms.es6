import { 
  CHANGE_ERROR_MESSAGE_FLAG,
  CHANGE_ISAUTOROOMSFETCH,
  REQUEST_ROOMS,
  RECEIVE_ROOMS,
  SELECTED_ROOM,
  INIT_ROOM } from '../actions/Rooms.es6'

const initialState = {
  rooms: [],
  selectedRoom: '',
  selectedRoomName: '',
  isAutoRoomsFetch: true,
  error_messageFlag: false,
  isFetchedRooms: true
}

function requestRooms(state = initialState, action) {
  switch (action.type) {
    case REQUEST_ROOMS:
      return Object.assign({}, state, {
        isFetchedRooms: action.isFetchedRooms
      })
    case RECEIVE_ROOMS:
      return Object.assign({}, state, {
        rooms: action.rooms,
        isAutoRoomsFetch: action.isAutoRoomsFetch,
        isFetchedRooms: action.isFetchedRooms
      })
    case SELECTED_ROOM:
      return Object.assign({}, state, {
        selectedRoom: action.selectedRoom,
        selectedRoomName: action.selectedRoomName
      })
    case CHANGE_ISAUTOROOMSFETCH:
      return Object.assign({}, state, {
        isAutoRoomsFetch: action.isAutoRoomsFetch
      })
    case CHANGE_ERROR_MESSAGE_FLAG:
      return Object.assign({}, state, {
        error_messageFlag: action.error_messageFlag
      })
    case INIT_ROOM:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default requestRooms