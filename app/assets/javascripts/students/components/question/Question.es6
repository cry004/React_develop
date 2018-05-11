import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Message } from './Message.es6'

import { requestQuestion,
  updateQuestionRead,
  resolveQuestion,
  unresolveQuestion } from '../../actions/question.es6'

import { isShowLoading } from '../../actions/loading.es6'

class Question extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {
    const { question, accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(requestQuestion(accessToken.accessToken, question.id))
  }
  componentDidMount() {
    const { accessToken, question, dispatch } = this.props
    if (question.unread === true) {
      dispatch(updateQuestionRead(accessToken.accessToken, question.id))
    }
  }
  componentWillReceiveProps(nextProps) {
    const { accessToken, question, dispatch } = this.props
    if (question.id !== nextProps.question.id && nextProps.unread === true) {
      dispatch(updateQuestionRead(accessToken.accessToken, nextProps.question.id))
    }
    if (question.isFetching === true && nextProps.question.isFetching === false) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false)) 
  }

  resolve() {
    const { accessToken, question, dispatch } = this.props
    dispatch(resolveQuestion(accessToken.accessToken, question.id))
  }
  unresolve() {
    const { accessToken, question, dispatch } = this.props
    dispatch(unresolveQuestion(accessToken.accessToken, question.id))
  }
  render() {
    const { question } = this.props
    return (
      <div className="page-question">
        {question.posts.map((message, i) =>
          <Message message={message} key={i} />
        )}
        {(() => {
          if (question.state.key === 'resolved') {
           return (
              <a className="el-button is-white" onClick={()=>this.unresolve()}>
                解決済みを取り消す
              </a>
            )
          } else if (question.state.key === 'answered') {
            return (
              <a className="el-button is-white" onClick={()=>this.resolve()}>
                解決済みにする
              </a>
            )
          }
        })()}
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    question: state.question
  }
}

export default connect(mapStateToProps)(Question);