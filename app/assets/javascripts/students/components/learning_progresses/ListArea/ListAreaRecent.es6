import React, { Component } from 'react'

import { Subject } from '../../Block/subject/Subject.es6'

export class ListAreaRecent extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { lastLearningSubjects, accessToken, dispatch } = this.props 
    if (lastLearningSubjects.length < 1) {
      return (
        <p className="el-text-nocontent">まだ最近の学習がありません。</p>
      )
    } else {
      return (
        <div>
          {lastLearningSubjects.map((subject, i) =>
            <Subject accessToken={accessToken} subject={subject} dispatch={dispatch} key={i} />
          )}
        </div>
      )
    }
  }
}