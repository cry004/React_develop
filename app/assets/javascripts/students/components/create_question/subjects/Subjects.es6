import React, { Component } from 'react'
import constants from '../../../constants.es6'
import { Subject } from './Subject.es6'

export class Subjects extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { accessToken, isChecked, dispatch } = this.props
    return(
      <div>
        <p className="heading">① 科目をひとつ選択してください。</p>
        <div className="subjects">
          {constants.subjects.map((subject, i) =>
            <Subject key={i} accessToken={accessToken} subject={subject} isChecked={isChecked} dispatch={dispatch} />
          )}
        </div>
      </div>
    )
  }
}





