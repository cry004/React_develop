import React, { Component } from 'react'
import classNames from 'classnames'

export class Subject extends Component {
  constructor(props) {
    super(props)
  }
  render() {

    const { courses, text, clickFunc, isActive, subject, changeSubject } = this.props
    const isSubject = !!subject ? true : false
    const linkClass = isActive === true ? 'is-active' : ''
    const listClass = `bl-tab-list is-${subject}`

    return (
      <li className={listClass}>
        <a className={linkClass} >
          {text}
        </a>        
        {(() => {
          if(courses.courses[subject]) {
            return (
              <ul className="bl-tab-list-subject">
                {courses.courses[subject].map((course, i) =>
                  <li key={i} onClick={changeSubject.bind(this, course.schoolyear, course.subject_key)}>
                    <a>{course.title.school_name||""}{course.title.subject_name||""} {course.title.subject_type||""} {course.title.subject_detail_name||""}</a>
                  </li>
                )}
              </ul>
            )
          }
        })()}
      </li>
    )
  }
}