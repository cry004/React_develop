import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'
import { Search } from './Search.es6'
import { Notifications } from './notifications/Notifications.es6'
import { Mypage } from './Mypage.es6'

import { createQuestion,
  updateCreateQuestionStatus } from '../../../actions/createQuestion.es6'

export class Header extends Component {
  constructor(props) {
    super(props)
  }
  createQuestion() {
    const { accessToken, dispatch } = this.props
    if (window.location.hash !== '#/create_question') {
      dispatch(updateCreateQuestionStatus("initial"))
      dispatch(createQuestion(accessToken.accessToken))
    }
  }
  render() {
    const { user, search, scroll, notifications, accessToken, dispatch } = this.props
    return (
      <div className="bl-header" style={{left: scroll.left }}>
        <Link to="/learning_progresses" className="bl-header-logo"></Link>
        <Search search={search} accessToken={accessToken} dispatch={dispatch} />
        <div className="bl-header-menu">
          <a className="bl-header-menu-question" onClick={()=> this.createQuestion()}>質問する</a>
          <Notifications notifications={notifications} accessToken={accessToken} dispatch={dispatch} user={user}/>
          <Mypage user={user} accessToken={accessToken} dispatch={dispatch} />
        </div>
      </div>
    )
  }
}
