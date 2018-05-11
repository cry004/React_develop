import React, { Component } from 'react'
import classNames from 'classnames'

export class PracticeText extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { video } = this.props
    let practice_url = video.practice_url
    let practice_answer_url = video.practice_answer_url
    let practiceTextDom
    
    if(practice_url != null && practice_answer_url != '' && practice_answer_url != null) {
      practiceTextDom = <div>
          <h5 className="title print">演習問題</h5>
          <a href={practice_url} target="_blank" className="el-button size-mini">問題</a>
          <a href={practice_answer_url} target="_blank" className="el-button size-mini">解答</a>
        </div>
    }
    
    let containerClass = classNames({'btns-area': (practice_url && practice_answer_url)})
    
    return (
      <div className={containerClass}>
        {practiceTextDom}
      </div>
    )
  }
}
