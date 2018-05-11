import React, { Component } from 'react'

import { SubjectCard } from './SubjectCard.es6'

export class ListArea extends Component {
  constructor(props) {
    super(props)
  }

  selectVideoList(subjectname) {
    const { dispatch } = this.props;
    window.location.hash = '/videos'
  }
  render() {
    const { courses, currentTab, accessToken, dispatch } = this.props
    let middle = []
    let high = []
    if (courses.courses[currentTab].length > 0) {
      courses.courses[currentTab].forEach((course) => {
        if (course.schoolyear === 'k') {
          high.push(course)
        } else {
          middle.push(course)
        }
      })
    }
    return(
      <div className="subject">
        <div className="subject-column">
          <p className="subject-column-heading">中学</p>
          {middle.map((subject, i) =>
            <SubjectCard subject={subject} currentTab={currentTab} accessToken={accessToken} dispatch={dispatch} key={i} />
          )}
        </div>
        <div className="subject-column">
          <p className="subject-column-heading">高校</p>
          {high.map((subject, i) =>
            <SubjectCard subject={subject} currentTab={currentTab} accessToken={accessToken} dispatch={dispatch} key={i} />
          )}
        </div>
      </div>
    )
  }
}