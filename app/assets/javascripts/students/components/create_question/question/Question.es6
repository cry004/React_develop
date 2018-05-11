import React, { Component } from 'react'

import { updateText } from '../../../actions/createQuestion.es6'

export class Question extends Component {
  constructor(props) {
    super(props)
  }
  changeText(e) {
    const { dispatch } = this.props
    dispatch(updateText(e.target.value))
  }
  render() {
    const { createQuestion, isVideo, dispatch } = this.props
    return(
      <div className="u-right container-text">
        <div className="container-heading">
          {(() => {
            if (isVideo === false) {
              return (
                <div>
                  <p className="heading">
                    ③ 質問を入力してください。
                  </p>
                  <p className="description">
                    質問は先生に伝わるように詳しく書いてください。
                  </p>
                </div>
              )
            }
          })()}
        </div>
        <textarea className="container-text-textarea" 
          placeholder="質問内容を入力…"
          value={createQuestion.text}
          onChange={(e) => this.changeText(e)}>
        </textarea>
      </div>
    )
  }
}





