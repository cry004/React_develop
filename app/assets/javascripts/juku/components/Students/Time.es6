import React, { Component } from 'react'

export class Time extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { periods } = this.props
    return (
      <div className="content is-time">
        {periods.map((period, j) =>
          <p className="time" key={j}>
            {period.start_time} 〜 {period.end_time}
          </p>
        )}
      </div>
    )
  }
}