import React, { Component } from 'react'

export class QuestionForInternalMember extends Component {
    constructor(props) {
    super(props)
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="question-for-internal-member">
        <p>
          この授業はトライ会員のみ質問できます。
        </p>
        <a className="el-button size-small is-blue" onClick={hidePopup}>OK</a>
      </div>
    )
  }
}