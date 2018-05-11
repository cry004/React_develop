import React, { Component } from 'react'
import { connect } from 'react-redux'
import moment from 'moment'

import { Calendar } from '../components/cal/Calendar.es6'

export class CurriculumDates extends Component {

  constructor(props) {
    super(props)
  }

  onSelect(date, previousDate, currentMonth) {
    if (moment(date).isSame(previousDate)) {
      return false;
    } else if (currentMonth.isSame(date, 'month')) {
      return true;
    }
    this.props.onCalChange(date)
  }

  hideCal() {
    this.props.onSetEditCalActive(false)
  }

  render() {
    const { this_date, isCalActive } = this.props

    return(
      <div className="calendar">
        <button className="calender" onClick={(e) => { this.props.onSetEditCalActive(true) }}>{this_date}</button>
        <div className="Calendar__container">
          <Calendar schedule_type={'day'}
            isActive={isCalActive}
            start_date={this_date}
            end_date={this_date}
            onSelect={this.onSelect}
            onCalHide={this.hideCal.bind(this)}
            onCalChange={this.props.onCalChange}
            page_type={'curriculum'} />
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    isCalStartActive: state.requestCurriculums.isCalStartActive,
    isCalEndActive: state.requestCurriculums.isCalEndActive
  }
}

export default connect(mapStateToProps)(CurriculumDates);