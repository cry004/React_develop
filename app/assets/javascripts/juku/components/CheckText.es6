import React, { Component } from 'react'
import classNames from 'classnames'

export class CheckText extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { video } = this.props
    let checktest_url = video.checktest_url
    let checktest_answer_url = video.checktest_answer_url
    let checkTextDom
    
    if(checktest_url != null && checktest_answer_url != '' && checktest_answer_url != null) {
      checkTextDom = <div>
          <h5 className="title print">確認テスト</h5>
          <a href={checktest_url} target="_blank" className="el-button size-mini">問題</a>
          <a href={checktest_answer_url} target="_blank" className="el-button size-mini">解答</a>
        </div>
    }
    
    let containerClass = classNames({'btns-area': (checktest_url && checktest_answer_url)})
    
    return (
      <div className={containerClass}>
        {checkTextDom}
      </div>
    )
  }
}