import React, { Component } from 'react'
import { Time } from './Time.es6'
import { Periods } from './Periods.es6'

export class List extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { searched_students, periods } = this.props
    return (
      <div className="container">
        <div className="headSection">
          <p className="head is-name">名前</p>
          <p className="head is-time">時間帯</p>
          <div className="is-week">
            <p className="head">月</p>
            <p className="head">火</p>
            <p className="head">水</p>
            <p className="head">木</p>
            <p className="head">金</p>
            <p className="head">土</p>
            <p className="head">日</p>
          </div>
        </div>
        {searched_students.map((student, i) =>
          <div className="list" key={i}>
            <div className="content is-name">
              <p className="grade">{student.schoolyear_name}</p>
              <p className="name">{student.student_name}さん</p>
            </div>
            <Time periods={periods} />
            <Periods periods={student.periods} />
          </div>
        )}
      </div>
    )
  }
}
