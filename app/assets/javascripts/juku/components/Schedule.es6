import React, { Component } from 'react'
import { connect } from 'react-redux'
import moment from 'moment'

import { changeIsCalActive, requestBoxes, changeScheduleType, selectedBox, initIsFetchedBox } from '../actions/Boxes.es6'
import { changeSubSubject } from '../actions/Curriculums.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'
import { Breadcrumbs } from '../components/Breadcrumbs.es6'
import { SystemMenu } from '../components/SystemMenu.es6'
import { ScheduleHeader } from '../components/ScheduleHeader.es6'
import { ScheduleTimelist } from '../components/ScheduleTimelist.es6'
import { ScheduleList } from '../components/ScheduleList.es6'
import { Loading } from '../components/Loading.es6'

export class Schedule extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {
    const { dispatch, boxes, access_token, classroom_id, start_date, end_date } = this.props
    dispatch(requestBoxes(boxes, access_token, classroom_id, start_date, end_date))

    //todo:ここでchangesubsubjectするべきじゃなさそう
    dispatch(changeSubSubject('', ''))
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(initIsFetchedBox())
    dispatch(initErrorMessage())
  }

  onChangeType(type) {
    const { dispatch, boxes, access_token, classroom_id, start_date } = this.props
    dispatch(changeScheduleType(type))
    if(type == 'day') {
      //start_date = end_dateする
      dispatch(requestBoxes(boxes, access_token, classroom_id, start_date, start_date))
    } else if(type == 'week') {
      //start_dateから週初めの日と週終わりを算出し、新しいstart_dateとend_dateを決める
      let mon = moment(new Date(start_date)).isoWeekday(1).format("YYYY-MM-DD")
      let sun = moment(new Date(start_date)).isoWeekday(7).format("YYYY-MM-DD")
      dispatch(requestBoxes(boxes, access_token, classroom_id, mon, sun))
    }
  }

  onBoxSelect(
      student_id,
      student_name,
      subject_id,
      schoolyear_key,
      box_id,
      agreement_id,
      period_id,
      date) {
    const { dispatch } = this.props
    dispatch(selectedBox(
      student_id,
      student_name,
      subject_id,
      schoolyear_key,
      box_id,
      agreement_id,
      period_id,
      date))
    window.location.hash = '/student'
  }

  showCal() {
    const { dispatch } = this.props
    dispatch(changeIsCalActive(true))
  }

  hideCal() {
    const { dispatch } = this.props
    dispatch(changeIsCalActive(false))
  }

  hideCalAndChangeDate(start_date, end_date) {
    const { dispatch, boxes, access_token, classroom_id } = this.props
    this.hideCal()
    dispatch(requestBoxes(boxes, access_token, classroom_id, start_date, end_date))
  }

  render() {
    const { items, periods, schedule_type, isCalActive, location, isFetchedBox } = this.props
    return(
      <div className="Content Schedule">
        <Breadcrumbs items={this.props.breadcrumbs} />
        <div className="Schedule__container">
          <SystemMenu pathname={location.pathname} />
          <Loading isFetched={isFetchedBox} />
          <div className="Schedule__contents">
            <ScheduleHeader
            isCalActive={isCalActive}
            start_date={this.props.start_date}
            end_date={this.props.end_date}
            schedule_type={schedule_type}
            onChangeType={this.onChangeType.bind(this)}
            onCalShow={this.showCal.bind(this)}
            onCalHide={this.hideCal.bind(this)}
            onCalChange={this.hideCalAndChangeDate.bind(this)} />
            <p className="Schedule__note">生徒ごとに当日の授業内容を設定してください。</p>
            <ScheduleTimelist schedule_type={schedule_type} periods={periods} />
            <ScheduleList schedule_type={schedule_type} items={items} onSelect={this.onBoxSelect.bind(this)} />
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName}],
    boxes: state.requestBoxes.boxes,
    items: state.requestBoxes.items,
    periods: state.requestBoxes.periods,
    access_token: state.requestAccessToken.access_token,
    classroom_id: state.requestRooms.selectedRoom,
    start_date: state.requestBoxes.start_date,
    end_date: state.requestBoxes.end_date,
    schedule_type: state.requestBoxes.schedule_type,
    student_id: state.requestBoxes.student_id,
    selected_box_id: state.requestBoxes.selected_box_id,
    selected_subject_id: state.requestBoxes.selected_subject_id,
    selected_schoolyear_key: state.requestBoxes.selected_schoolyear_key,
    selected_agreement_id: state.requestBoxes.selected_agreement_id,
    selected_period_id: state.requestBoxes.selected_period_id,
    selected_date: state.requestBoxes.selected_date,
    isCalActive: state.requestBoxes.isCalActive,
    isFetchedBox: state.requestBoxes.isFetchedBox
  }
}

export default connect(mapStateToProps)(Schedule);
