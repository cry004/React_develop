import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { requestLogin,
  loginErrorMessage,
  initLogin } from '../../actions/login.es6'


//initilize
import { initUserAll } from '../../actions/user.es6'
import { initUseragentAll } from '../../actions/useragent.es6'
import { initAccessToken } from '../../actions/accessToken.es6'
import { initNewsAll } from '../../actions/news.es6'
import { initTeacherAll } from '../../actions/teacher.es6'
import { isShowLoading } from '../../actions/loading.es6'
import { initLearningProgressAll } from '../../actions/learningProgresses.es6'
import { initBookmarks } from '../../actions/bookmark.es6'
import { initQuestions } from '../../actions/questions.es6'
import { initQuestion } from '../../actions/question.es6'
import { initTeacherRecommends } from '../../actions/teacher.es6'
import { initJukuLearnings } from '../../actions/jukuLearnings.es6'
import { initVideo } from '../../actions/video.es6'
import { initCreateQuestionAll } from '../../actions/createQuestion.es6'
import { initRankings } from '../../actions/rankings.es6'
import { initRankingsClassroom } from '../../actions/rankingsClassroom.es6'

class Login extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    localStorage.clear()
    const { dispatch } = this.props
    //fixme: もっと良い初期化方法考える
    dispatch(isShowLoading(false))
    dispatch(loginErrorMessage([]))
    dispatch(initUserAll())
    dispatch(initUseragentAll())
    dispatch(initLogin())
    dispatch(initAccessToken())
    dispatch(loginErrorMessage([]))
    dispatch(initNewsAll())
    dispatch(initTeacherAll())
    dispatch(initLearningProgressAll())
    dispatch(initBookmarks())
    dispatch(initQuestions())
    dispatch(initTeacherRecommends())
    dispatch(initJukuLearnings())
    dispatch(initVideo())
    dispatch(initQuestion())
    dispatch(initRankings())
    dispatch(initRankingsClassroom())
    dispatch(initCreateQuestionAll())
  }
  componentWillReceiveProps(nextProps) {
    const { accessToken } = this.props
    if (nextProps.accessToken.isAccessToken === true) {
      window.location.hash = '/learning_progresses'
    }
  }

  login(e) {
    e.preventDefault(e)
    const { login, dispatch } = this.props
    let id = this.idDom.value
    let password = this.passwordDom.value
    if (id === "") {
      dispatch(loginErrorMessage(["IDを入力してください"]))
      return false
    }　else if (password === "") {
      dispatch(loginErrorMessage(["パスワードを入力してください"]))
      return false
    }
    if (login.isSending === false) {
      dispatch(requestLogin(id, password))
    }
  }
  resetError() {
    const { login, dispatch } = this.props
    if(login.errorMessage !== "") {
      dispatch(loginErrorMessage([]))
    }
  }
  render() {
    const { login, useragent } = this.props
    const buttonText = login.errorMessage.length > 0 ? login.errorMessage[0] : 'ログイン'
    const buttonClass = classNames('el-button', {
      'is-red': login.errorMessage.length > 0,
      'is-blue': login.errorMessage.length < 1
    })
    return (
      <div className="page-login">
        <div>
          <p className="el-heading">ログイン画面</p>
          <form>
          {/*<form onSubmit={(e) => this.login(e)}>*/}
            <div className="el-textbox has-icon is-mail">
              <input type="text" placeholder="ID" ref={(id) => this.idDom = id}  onChange={() => this.resetError()} />
            </div>
            <div className="el-textbox has-icon is-key">
              <input type="password" placeholder="パスワード" ref={(password) => this.passwordDom = password} onChange={() => this.resetError()}/>
            </div>
            <button onClick={(e) => this.login(e)} className={buttonClass}>{buttonText}</button>
            <p className="forget">パスワードを忘れた方は<a href="/password_reminder_page/index.html">こちら</a></p>
          </form>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    login: state.login,
    accessToken: state.accessToken,
    useragent: state.useragent
  }
}

export default connect(mapStateToProps)(Login);
