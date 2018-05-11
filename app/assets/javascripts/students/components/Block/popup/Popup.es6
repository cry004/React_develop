import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'
import classNames from 'classnames'


import { hidePopup } from '../../../actions/popup.es6'

import { Level } from './inner/Level.es6'
import { Trophy } from './inner/Trophy.es6'
import { Textbook } from './inner/Textbook.es6'
import { Questions } from './inner/Questions.es6'
import { History } from './inner/History.es6'
import { Bookmark } from './inner/Bookmark.es6'
import { RequestPoint } from './inner/RequestPoint.es6'
import { CompleteRequestPoint } from './inner/CompleteRequestPoint.es6'
import { PostQuestion } from './inner/PostQuestion.es6'
import { PostQuestionDraft } from './inner/PostQuestionDraft.es6'
import { SubmitQuestion } from './inner/SubmitQuestion.es6'
import { Vacation } from './inner/Vacation.es6'
import { NotAcceptQuestion } from './inner/NotAcceptQuestion.es6'
import { QuestionForInternalMember } from './inner/QuestionForInternalMember.es6'

export class Popup extends Component {
  constructor(props) {
    super(props)
  }
  hidePopup() {
    const { dispatch } = this.props
    dispatch(hidePopup())
  }
  render() {
    const { popup, user, createQuestion, accessToken, locationHash, dispatch } = this.props
    const popupClass = classNames('bl-popup', { 'u-hidden': popup.isHidden })
    const innerClass = `bl-popup-inner is-${popup.popupType}`
    return (
      <div className={popupClass}>
        <div className="bl-popup-overlay"></div>
        <div className={innerClass}>
          <Level user={user} args={popup.args}  hidePopup={this.hidePopup.bind(this)} />
          <Trophy hidePopup={this.hidePopup.bind(this)} args={popup.args} dispatch={dispatch} />
          <Textbook hidePopup={this.hidePopup.bind(this)} accessToken={accessToken} dispatch={dispatch} />
          <Questions args={popup.args} accessToken={accessToken} dispatch={dispatch} hidePopup={this.hidePopup.bind(this)} />
          <History args={popup.args} accessToken={accessToken} dispatch={dispatch} hidePopup={this.hidePopup.bind(this)} />
          <Bookmark args={popup.args} accessToken={accessToken} hidePopup={this.hidePopup.bind(this)} dispatch={dispatch} />
          <RequestPoint args={popup.args} hidePopup={this.hidePopup.bind(this)} accessToken={accessToken} createQuestion={createQuestion} dispatch={dispatch} />
          <CompleteRequestPoint hidePopup={this.hidePopup.bind(this)} />
          <PostQuestion hidePopup={this.hidePopup.bind(this)} locationHash={locationHash} />
          <PostQuestionDraft hidePopup={this.hidePopup.bind(this)} locationHash={locationHash} />
          <SubmitQuestion hidePopup={this.hidePopup.bind(this)} accessToken={accessToken} dispatch={dispatch} args={popup.args} />
          <Vacation accessToken={accessToken} dispatch={dispatch} hidePopup={this.hidePopup.bind(this)} args={popup.args} />
          <NotAcceptQuestion args={popup.args} hidePopup={this.hidePopup.bind(this)} />
          <QuestionForInternalMember hidePopup={this.hidePopup.bind(this)} />
        </div>
      </div>
    )
  }
}