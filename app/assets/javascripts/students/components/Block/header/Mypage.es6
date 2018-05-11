import React, { Component } from 'react'
import { Link } from 'react-router-dom'

import { requestLogout } from '../../../actions/login.es6'

export class Mypage extends Component {
  constructor(props) {
    super(props)
  }
  logout() {
    const { accessToken, dispatch } = this.props
    dispatch(requestLogout(accessToken.accessToken))
  }
  render() {
    const { user } = this.props
    const iconClass = `bl-header-menu-mypage-icon is-${parseInt(user.avatar, 10)}`
    return (
      <div className="bl-header-menu-mypage">
        <a className={iconClass}></a>
        <div className="el-menu is-mypage">
          <div className="el-menu-header u-clearfixs">
            <span className="el-menu-header-name">{user.nickName}</span>さん <Link className="u-right" to="/settings_profile">プロフィールを編集する</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/news">トライからのお知らせ</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/workbooks">授業テキストの購入</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/settings_textbooks">教科書の設定（中学生のみ）</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/settings_privacy">プライバシーの設定</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/about">Try ITについて</Link>
          </div>
          <div className="el-menu-list">
            <a href="https://www.try-it.jp/users/sign_in/" target="_blank">管理者ログイン（旧保護者ログイン）</a>
          </div>
          <div className="el-menu-list">
            <Link to="/terms">利用規約及びプライバシーポリシー</Link>
          </div>
          <div className="el-menu-list">
            <Link to="/commerce_law">特定商取引法に関する表示</Link>
          </div>
          <div className="el-menu-list">
            <a onClick={()=> this.logout()}>ログアウト</a>
          </div>
        </div>
      </div>
    )
  }
}