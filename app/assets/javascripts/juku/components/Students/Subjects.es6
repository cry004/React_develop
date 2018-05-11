import React, { Component } from 'react'

export class Subjects extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { subjects, row, column } = this.props
    let weekClass = `week column${column} row${row}`
    return (
      <div className={weekClass}>
        {subjects.map((subject, i) =>
          <p key={i} style={{color: subject.subject_color_code}} >
            {subject.subject_name || "　" }
          </p>
        )}
      </div>
    )
  }
}