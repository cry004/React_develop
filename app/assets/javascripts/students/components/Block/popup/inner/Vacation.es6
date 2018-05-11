import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { createMarkup } from '../../../../util/createMarkup.es6'

import { callCreateQuestion,
  callCreateQuestionByVideo } from '../../../../actions/createQuestion.es6'

export class Vacation extends Component {
  constructor(props) {
    super(props)
  }
  createQuestion() {
    const { dispatch, args, accessToken, hidePopup } = this.props
    if (args.popupType === 'noVideo') {
      dispatch(callCreateQuestion(accessToken.accessToken))
    } else {
      dispatch(callCreateQuestionByVideo(accessToken.accessToken, args.videoId, args.position))
    }
    hidePopup()
  }
  render() {
    const { hidePopup, args } = this.props
    const messages = args.messages || []
    return (
      <div className="vacation">
        <p className="vacation-title">
          質問の下書きを作成しますか？
        </p>
        {messages.map((message, i) =>
          <p key={i} className="vacation-description" dangerouslySetInnerHTML={createMarkup(message)} />
        )}
        <a className="el-button size-small is-white" onClick={hidePopup}>やめる</a>
        <a className="el-button size-small is-blue" onClick={this.createQuestion.bind(this)}>
        質問の下書きを作成する</a>
      </div>
    )
  }
} 