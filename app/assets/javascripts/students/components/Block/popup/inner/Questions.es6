import React, { Component } from 'react'

import { deleteQuestion } from '../../../../actions/questions.es6'

export class Questions extends Component {
  constructor(props) {
    super(props)
  }
  deleteQuestion() {
    const { args, accessToken, dispatch } = this.props
    dispatch(deleteQuestion(accessToken.accessToken, args.deleteId))
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="questions">
        <p>
          この質問を削除しますか？
          <br/>
          (復帰することはできません)
        </p>
        <a className="el-button size-small is-white" onClick={hidePopup}>キャンセル</a>
        <a className="el-button size-small is-red" onClick={()=> this.deleteQuestion()}>削除する</a>
      </div>
    )
  }
}