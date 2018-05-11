import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { requestPrefectures, selectedPrefecture } from '../actions/Prefectures.es6'
import { requestRooms, selectedRoom, setErrorMessageFlag, setIsAutoRoomsFetch } from '../actions/Rooms.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'

import { initBoxState } from '../actions/Boxes.es6'
import { initCurriculums } from '../actions/Curriculums.es6'
import { initHistories } from '../actions/History.es6'
import { initLearnings } from '../actions/Learnings.es6'
import { initReport } from '../actions/Reports.es6'
import { initRoom } from '../actions/Rooms.es6'
import { initStudents } from '../actions/Students.es6'
import { initSimulator } from '../actions/Simulator.es6'

export class RoomSelect extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {
    const { dispatch, prefectures, selectedPrefecture, access_token } = this.props
    dispatch(requestPrefectures(access_token, selectedPrefecture || '01'))
    localStorage.clear()
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(setIsAutoRoomsFetch(true))
    dispatch(initErrorMessage())
  }

  prefecturesOnChange(prefecture_id) {
    const { dispatch, rooms, access_token } = this.props
    dispatch(selectedPrefecture(prefecture_id))
    dispatch(requestRooms(rooms, access_token, prefecture_id))
  }

  roomsOnChange(room_id) {
    const { dispatch, rooms } = this.props
    let room_name
    rooms.map(room => {
      if(room.classroom_id == room_id) {
        room_name = room.classroom_name
      }
    })
    dispatch(selectedRoom(room_id, room_name))
  }

  btnClick(e) {
    const { dispatch, selectedPrefecture, selectedRoom, selectedRoomName } = this.props
    if(selectedPrefecture && selectedRoom) {
      dispatch(setErrorMessageFlag(false))
      window.location.hash = '/schedule'
    } else {
      dispatch(setErrorMessageFlag(true))
    }
  }

  render() {
    const { prefectures, selectedPrefecture, rooms, onChange, value, error_messageFlag, isFetchedRooms } = this.props
    let errorClass = classNames("error", {active: error_messageFlag})
    let roomSelectClass = classNames("roomSelectBox", {'is-fetched': isFetchedRooms})
    return(
      <div className="Content">
        <div className="RoomSelect">
          <select value={selectedPrefecture} onChange={e => this.prefecturesOnChange(e.target.value)}>
            {prefectures.map(option =>
              <option value={option.id} key={option.name}>
                {option.name}
              </option>)
            }
          </select>
          <br />
          <select onChange={e => this.roomsOnChange(e.target.value)}>

            <option value='' key='教室を選択'>教室を選択</option>
            {rooms.map(option =>
              <option value={option.classroom_id} key={option.classroom_name}>
                {option.classroom_name}
              </option>)
            }
          </select>
          <br />
          <input
            className="el-button size-large"
            type="button"
            value="教室のページヘ"
            onClick={e => this.btnClick(e)}
          />
          <p className={errorClass}>エラー：「都道府県」と「教室」の両方を選択してください</p>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    isAccessToken: state.requestAccessToken.isAccessToken,
    isPrefecturesFetch: false,
    isAutoRoomsFetch: state.requestRooms.isAutoRoomsFetch,
    prefectures: state.requestPrefectures.prefectures,
    selectedPrefecture: state.requestPrefectures.selectedPrefecture,
    rooms: state.requestRooms.rooms,
    selectedRoom: state.requestRooms.selectedRoom,
    selectedRoomName: state.requestRooms.selectedRoomName,
    access_token: state.requestAccessToken.access_token,
    error_messageFlag: state.requestRooms.error_messageFlag,
    access_token: state.requestAccessToken.access_token,
    isAccessToken: state.requestAccessToken.isAccessToken,
    isFetchedRooms: state.requestRooms.isFetchedRooms
  }
}

export default connect(mapStateToProps)(RoomSelect);

