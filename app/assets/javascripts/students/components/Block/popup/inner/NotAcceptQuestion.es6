import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { createMarkup } from '../../../../util/createMarkup.es6'

export class NotAcceptQuestion extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { hidePopup, args } = this.props
    const messages = args.messages || []
    return (
      <div className="not-accept-question">
        <p className="not-accept-question-title">
          ただ今、質問を受け付けておりません。
        </p>
        {messages.map((message, i) =>
          <p key={i} className="not-accept-question-description" dangerouslySetInnerHTML={createMarkup(message)} />
        )}
        <a className="el-button size-small is-blue" onClick={hidePopup}>OK</a>
      </div>
    )
  }
} 