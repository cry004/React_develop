import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Calendar } from '../../components/cal/Calendar.es6'
import moment from 'moment'

export class Dates extends Component {

  constructor(props) {
    super(props)
  }

  onSelect(date, previousDate, currentMonth) {
    const { onCalChange } = this.props

    if (moment(date).isSame(previousDate)) {
      return false;
    }
    onCalChange(date)
  }

  hideCal() {
    this.props.onSetEditCalActive(false)
  }

  render() {
    const { this_date, schedule_type, start_date, end_date, isCalActive, onCalShow, onCalHide, onCalChange } = this.props
    
    return(
      <div className="calendar">
        <button className="calender" onClick={(e) => { this.props.onSetEditCalActive(true) }}>{moment(this_date).format('YYYY/MM/DD')}</button>
        <div className="Calendar__container">
          <Calendar schedule_type={'day'}
            isActive={isCalActive}
            start_date={this_date}
            end_date={this_date}
            onSelect={this.onSelect.bind(this)}
            onCalHide={this.hideCal.bind(this)}
            onCalChange={onCalChange}
            page_type={'simulator'} />
        </div>
      </div>
    )
  }
}