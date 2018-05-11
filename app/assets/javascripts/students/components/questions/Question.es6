import React, { Component } from 'react'
import classNames from 'classnames'

import { showPopup, hidePopup } from '../../actions/popup.es6'
import { updateDeleteId } from '../../actions/questions.es6'
import { updateCurrentQuestion } from '../../actions/question.es6'
import { updateCreateQuestionId,
  updateCreateQuestionStatus } from '../../actions/createQuestion.es6'

export class Question extends Component {
  constructor(props) {
    super(props)
  }
  deleteQuestion(e, questionId) {
    const { dispatch } = this.props
    e.stopPropagation()
    dispatch(showPopup('questions', { 
      deleteId: questionId 
    }))
  }
  selectQuestion(e, question) {
    const { dispatch } = this.props
    if (question.state.key === 'initial' || question.state.key === 'draft') {
      dispatch(updateCreateQuestionId(question.id, question.state.key))
      window.location.hash = '/create_question'
    } else {
      dispatch(updateCurrentQuestion(question.id, question.state.key))
      window.location.hash = '/question'
    }
  }
  render() {
    const { question } = this.props
    const statusClass = `card-status is-${question.state.key} unread-${question.unread}`
    const subjectClass = !!question.subject ? `card-subject u-color-${question.subject.key}` : `card-subject`
    const imageUrl = !!question.image? question.image.desktop.resource_url : ""
    const subjectName = !!question.subject? question.subject.name : ""
    return (
      <a className="card u-clearfix" onClick={(e)=> this.selectQuestion(e, question)}>
        {(() => {
          if(question.state.key === 'refused' 
            || question.state.key === 'initial' 
            || question.state.key === 'draft' ) {
            return (
              <div className="card-delete" onClick={(e) => this.deleteQuestion(e, question.id)}>
              </div>
            )
          }
        })()}
        <div className="card-image u-left">
          {(() => {
            if (!!imageUrl) {
              return (
                <img src={imageUrl} />
              )
            } else {
              return (
                <div className="card-image-noimage"></div>
              )
            }
          })()}
        </div>
        <div className="u-left card-textarea">
          <p className={statusClass}>
            {question.state.name}
          </p>
          <p className="card-question">
            {question.title}
          </p>
          <p className={subjectClass}>
            {subjectName}
          </p>
          <p className="card-date">
            {question.date}
          </p>
        </div>
      </a>
    )
  }
}