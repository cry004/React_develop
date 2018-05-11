import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'

import { initAccessToken } from '../../actions/accessToken.es6'

class Top extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { dispatch } = this.props
    dispatch(initAccessToken())
  }
  linkSignUp() {
    ga('send', 'event', 'Try IT をはじめる', 'click', 'start', 1)
  }
  render() {
    const { hostname } = this.props
    return (
      <div className="page-top">
        <div>
          <div className="logo"></div>
          <Link to="/login" className="el-button is-blue">ログイン</Link>
          <a onClick={() => this.linkSignUp()} href={hostname.www} target="_blank" className="el-button is-blue">新規登録</a>
          <div className="link">
            <Link to="/terms">利用規約及びプライバシーポリシー</Link>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    hostname: state.hostname
  }
}

export default connect(mapStateToProps)(Top);