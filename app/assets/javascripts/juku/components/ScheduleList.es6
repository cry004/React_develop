import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'
import moment from 'moment'

import { Box } from '../components/Box.es6'

export class ScheduleList extends Component {

  constructor(props) {
    super(props)
  }

  changeType(type) {
    this.props.onChangeType(type)
  }

  dateTd(schedule_type, date, periods) { 
    if(schedule_type == 'day') {
      return <td className="Schedule__list-item"><table className="Schedule__box num">
          <tbody>
            {periods[0].boxes.map((box, boxIndex) => 
              <tr key={boxIndex}>
                <td className="Schedule__list-item num">{boxIndex + 1}</td>
              </tr>
            )}
          </tbody>
        </table></td>
    } else if(schedule_type == 'week') {
      return <td className="Schedule__list-item date">{date}</td>
    }
  }
  
  scheduleRowClassName(holiday_flag, date) {
    return classNames('Schedule__row', {holiday: holiday_flag}, {today: (date == moment().format('YYYYMMDD'))})
  }

  render() {
    const { schedule_type, items } = this.props
    return(
      <table className="Schedule__list">
        <tbody>
          {items.map((result, index) =>
            <tr key={index} className={this.scheduleRowClassName(result.holiday_flag, result.date)}>
              {this.dateTd(schedule_type, moment(result.date).format('MM月DD日（ddd)'), result.periods)}
              {result.periods.map((period, periodIndex) =>
                <td className="Schedule__list-item" key={periodIndex}>
                  <table className="Schedule__box">
                    <tbody>
                      {period.boxes.map((box, boxIndex) => {
                        box.period_id = period.period_id
                        return <tr key={`${periodIndex}.${boxIndex}`}>
                          <Box 
                          box={box}
                          onSelect={this.props.onSelect}
                          date={moment(result.date).format('YYYY-MM-DD')} />
                        </tr>
                        }
                      )}
                    </tbody>
                  </table>
                </td>
              )}
            </tr>
          )}
        </tbody>
      </table>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(ScheduleList);
