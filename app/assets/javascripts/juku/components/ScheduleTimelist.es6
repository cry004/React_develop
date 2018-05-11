import React, { Component } from 'react'
import { connect } from 'react-redux'

export class ScheduleTimelist extends Component {

  constructor(props) {
    super(props)
  }

  changeType(type) {
    this.props.onChangeType(type)
  }

  render() {
    const { schedule_type, periods } = this.props
    let header
    if(schedule_type == 'day') {
      header = 'No.'
    } else if(schedule_type == 'week') {
      header = '日付'
    }
    return(
      <div>
        <ul className="Schedule__timeList">
          <li className="Schedule__timeList-item date">{header}</li>
          {periods.map(result =>
            <li className="Schedule__timeList-item" key={result.id}>{result.start_time} 〜 {result.end_time}</li>
          )}
        </ul>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(ScheduleTimelist);