import React, { Component } from 'react'
import { Link } from 'react-router-dom'

import { sendPointRequest } from '../../../../actions/createQuestion.es6'

export class RequestPoint extends Component {
    constructor(props) {
    super(props)
  }
  requestPoint() {
    const { hidePopup, createQuestion, accessToken, dispatch } = this.props
    if (createQuestion.isRequestingPoint === false) {
      dispatch(sendPointRequest(accessToken.accessToken))  
    }
  }
  render() {
    const { hidePopup, args } = this.props
    if (args.isNewUser === true) {
      return (
        <div className="requestpoint">
          <p>
            マイページにアクセスいただき、
            <br/>
            ポイントの利用設定をお願いします。
          </p>
          <a className="el-button size-small is-white" onClick={hidePopup}>あとで</a>
          <a className="el-button size-small is-blue" href="https://www.try-it.jp/users/sign_in/" target="_blank">マイページへ</a>
        </div>
      )
    } else {
      return (
        <div className="requestpoint">
          <p>
            保護者の方にリクエストして、
            <br/>
            ポイントを増やしてもらいましょう。
          </p>
          <a className="el-button size-small is-white" onClick={hidePopup}>キャンセル</a>
          <a className="el-button size-small is-blue" onClick={()=> this.requestPoint()}>
          リクエストする</a>
        </div>
      )    
    }
  }
}