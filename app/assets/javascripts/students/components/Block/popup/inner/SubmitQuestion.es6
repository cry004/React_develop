import React, { Component } from 'react'
import { callUpdateQuestion,
  callUpdateQuestionByVideo } from '../../../../actions/createQuestion.es6'

export class SubmitQuestion extends Component {
  constructor(props) {
    super(props)
  }
  submitQuestion() {
    const { args, accessToken, dispatch } = this.props
    if (args.popupType === 'noVideo') {
      dispatch(callUpdateQuestion(accessToken.accessToken, args.questionId, args.createFlag, args.withoutVideo))
      ga('send', 'event', 'この内容で質問する', 'click', 'pc_question_free_ask', 1)
    } else {
      dispatch(callUpdateQuestionByVideo(accessToken.accessToken, args.questionId, args.createFlag, args.withVideo))
      ga('send', 'event', 'この内容で質問する', 'click', 'pc_question_eizojugyo_ask', 1)
    }
  }
  render() {
    const { hidePopup, args } = this.props
    return (
      <div className="submit-question">
        <p>
          質問を削除しますか？
          <br/>
          (500ポイント消費します)
        </p>
        <a className="el-button size-small is-white" onClick={hidePopup}>キャンセル</a>
        <a className="el-button size-small is-blue" onClick={()=> this.submitQuestion()}>質問する</a>
      </div>
    )
  }
}