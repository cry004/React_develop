import React, { Component } from 'react'
import { selectSubject } from '../../../actions/createQuestion.es6'


export class Subject extends Component {
  constructor(props) {
    super(props)
  }
  selectSubject(subject) {
    const { dispatch } = this.props
    dispatch(selectSubject(subject))
  }
  render() {
    const { subject, isChecked, dispatch } = this.props
    const subjectClass = `subject is-${subject.title}`
    const checkboxClass = `is-${subject.title}`
    return(
      <div className={subjectClass}>
        <input id={subject.title} type="radio" name="subject" value={subject.title} checked={isChecked(subject.title)} onChange={() => this.selectSubject(subject.title)} />
        <label htmlFor={subject.title} className={checkboxClass}></label>
      </div>
    )
  }
}