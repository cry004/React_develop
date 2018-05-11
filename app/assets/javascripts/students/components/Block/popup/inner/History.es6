import React, { Component } from 'react'

import { deleteHistory } from '../../../../actions/history.es6'

export class History extends Component {
  constructor(props) {
    super(props)
  }
  deleteHistory() {
    const { args, accessToken, dispatch } = this.props
    dispatch(deleteHistory(accessToken.accessToken, args.deleteId))
    //hidePopup()
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="history">
        <p>
          この授業を視聴履歴から削除しますか？
        </p>
        <a className="el-button size-small is-white" onClick={hidePopup}>キャンセル</a>
        <a className="el-button size-small is-blue" onClick={()=> this.deleteHistory()}>削除する</a>
      </div>
    )
  }
}