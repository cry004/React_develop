import React, { Component } from 'react'

import { deleteBookmark } from '../../../../actions/bookmark.es6'

export class Bookmark extends Component {
  constructor(props) {
    super(props)
  }
  deleteBookmark() {
    const { args, accessToken, hidePopup, dispatch } = this.props
    dispatch(deleteBookmark(accessToken.accessToken, args.deleteId))
    hidePopup()
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="bookmark">
        <p>
          この授業のブックマークをはずしますか？
        </p>
        <a className="el-button size-small is-white" onClick={hidePopup}>キャンセル</a>
        <a className="el-button size-small is-blue" onClick={()=> this.deleteBookmark()}>はずす</a>
      </div>
    )
  }
}