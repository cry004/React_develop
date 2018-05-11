import React, { Component } from 'react'
import { Link } from 'react-router-dom'

import { hideSchoolbookDialogs } from '../../../../actions/user.es6'

export class Textbook extends Component {
  constructor(props) {
    super(props)
  }
  deleteTextbook() {
    const { hidePopup } = this.props
    hidePopup()
  }
  linkToSettingBooks() {
    const { accessToken, hidePopup, dispatch } = this.props
    hidePopup()
    dispatch(hideSchoolbookDialogs(accessToken.accessToken))
    window.location.hash = "/settings_textbooks"
  }
  clickCancel() {
    const { accessToken, hidePopup, dispatch } = this.props
    hidePopup()
    dispatch(hideSchoolbookDialogs(accessToken.accessToken))
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="textbook">
        <p>
          Try IT へようこそ！
          <br/>
          <br/>
          中学生は教科書の設定ができます。
          <br/>
          設定しますか？
        </p>
        <a className="el-button size-small is-white" onClick={()=> this.clickCancel()}>キャンセル</a>
        <a className="el-button size-small is-blue" onClick={()=> this.linkToSettingBooks()}>
        設定する</a>
      </div>
    )
  }
}