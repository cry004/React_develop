import React, { Component } from 'react'
import { connect } from 'react-redux'
import moment from 'moment'

import { edateToJdate } from '../utils/Utils.js'
import { Calendar } from '../components/cal/Calendar.es6'

moment.locale('ja', {
  weekdays: ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
  weekdaysShort: ["日", "月", "火", "水", "木", "金", "土"]
})

export class ScheduleHeader extends Component {

  constructor(props) {
    super(props)
  }

  changeType(type) {
    this.props.onChangeType(type)
  }

  onSelect(date, previousDate, currentMonth) {
    if (moment(date).isSame(previousDate)) {
      return false;
    } else if (currentMonth.isSame(date, 'month')) {
      return true;
    }
    this.props.onCalChange(date, date)
  }

  onSelectToday() {
    let formattedDate = moment().format("YYYY-MM-DD")
    this.props.onCalChange(formattedDate, formattedDate)
  }
  onSelectPrevDay() {
    let formattedDate = moment(this.props.start_date).subtract(1, 'days').format("YYYY-MM-DD")
    this.props.onCalChange(formattedDate, formattedDate)
  }
  onSelectNextDay() {
    let formattedDate = moment(this.props.start_date).add(1, 'days').format("YYYY-MM-DD")
    this.props.onCalChange(formattedDate, formattedDate)
  }
  onSelectThisWeek() {
    let mon = moment().isoWeekday(1).format("YYYY-MM-DD")
    let sun = moment().isoWeekday(7).format("YYYY-MM-DD")
    this.props.onCalChange(mon, sun)
  }
  onSelectPrevWeek() {
    let mon = moment(this.props.start_date).subtract(7, 'days').isoWeekday(1).format("YYYY-MM-DD")
    let sun = moment(this.props.start_date).subtract(7, 'days').isoWeekday(7).format("YYYY-MM-DD")
    this.props.onCalChange(mon, sun)
  }
  onSelectNextWeek() {
    let mon = moment(this.props.start_date).add(7, 'days').isoWeekday(1).format("YYYY-MM-DD")
    let sun = moment(this.props.start_date).add(7, 'days').isoWeekday(7).format("YYYY-MM-DD")
    this.props.onCalChange(mon, sun)
  }

  render() {
    const { schedule_type, start_date, end_date, isCalActive, onCalShow, onCalHide } = this.props
    let headerDOM
    let jStart_date = edateToJdate(start_date)
    let jEnd_date = edateToJdate(end_date, 'month')

    if(schedule_type == 'day') {
      headerDOM = <div className="Schedule__header">
        <div className="Schedule__header-left">
          <input type="button" className="el-button size-small color-light is-today" value="今日" onClick={(e) => this.onSelectToday()} />
          <input type="button" className="el-button size-small color-light" value="<" onClick={(e) => this.onSelectPrevDay()} />
          <input type="button" className="el-button size-small color-light" value=">" onClick={(e) => this.onSelectNextDay()} />
          <div className="Calendar__container">
            <input type="button" className="date week small" value={jStart_date} onClick={(e) => onCalShow()} />
            <Calendar 
            schedule_type={schedule_type}
            isActive={isCalActive} 
            date={moment(start_date, "YYYY-MM-DD")} 
            start_date={start_date}
            end_date={end_date}
            onSelect={this.onSelect}
            onCalHide={this.props.onCalHide} 
            onCalChange={this.props.onCalChange} />
          </div>
        </div>
        <div className="Schedule__header-right">
          <input type="button" className="el-button color-light size-small color-active" value="日" onClick={(e) => this.changeType('day')} />
          <input type="button" className="el-button color-light size-small" value="週" onClick={(e) => this.changeType('week')} />
        </div>
      </div>
    } else if(schedule_type == 'week') {
      headerDOM = <div className="Schedule__header">
        <div className="Schedule__header-left">
          <input type="button" className="el-button size-small color-light is-today" value="今週" onClick={(e) => this.onSelectThisWeek()} />
          <input type="button" className="el-button size-small color-light" value="<" onClick={(e) => this.onSelectPrevWeek()} />
          <input type="button" className="el-button size-small color-light" value=">" onClick={(e) => this.onSelectNextWeek()} />
          <div className="Calendar__container">
            <input type="button" className="date week small" value={jStart_date + '〜' + jEnd_date} onClick={(e) => onCalShow()} />
            <Calendar 
            schedule_type={schedule_type}
            isActive={isCalActive} 
            date={moment(start_date, "YYYY-MM-DD")} 
            start_date={start_date}
            end_date={end_date}
            onSelect={this.onSelect}
            onCalHide={this.props.onCalHide} 
            onCalChange={this.props.onCalChange} />
          </div>
        </div>
        <div className="Schedule__header-right">
          <input type="button" className="el-button color-light size-small" value="日" onClick={(e) => this.changeType('day')} />
          <input type="button" className="el-button color-light size-small color-active" value="週" onClick={(e) => this.changeType('week')} />
        </div>
      </div>
    }
    return(
      <div>
        {headerDOM}
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(ScheduleHeader);