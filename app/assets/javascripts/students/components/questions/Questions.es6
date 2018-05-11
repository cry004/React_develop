import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Question } from './Question.es6'

import { showPopup, hidePopup } from '../../actions/popup.es6'
import { initQuestions, requestQuestions } from '../../actions/questions.es6'
import { initPager,
  updateCurrentPage } from '../../actions/pager.es6'
import { isShowLoading } from '../../actions/loading.es6'

class Questions extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(initQuestions())
    dispatch(updateCurrentPage(1))
    dispatch(requestQuestions(accessToken.accessToken , 1))
  }
  componentWillReceiveProps(nextProps) {
    const { questions, dispatch } = this.props
    if (questions.isFetching === true && nextProps.questions.isFetching === false) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  updatePage() {
    const { pager, questions, accessToken, dispatch } = this.props
    if (questions.isFetching === false) {
      dispatch(requestQuestions(accessToken.accessToken , pager.currentPage + 1))  
    }
  }

  render() {
    const { questions, pager, dispatch } = this.props
    if (questions.questions.length < 1) {
      return (
        <p className="el-text-nocontent no-header">まだ質問がありません。</p>
      )
    } else {
     return (
        <div className="page-questions">
          {questions.questions.map((question, i) =>
            <Question question={question} dispatch={dispatch} key={i} />
          )}
          {(() => {
            if (pager.isLastPage === false) {
              return (
                <a className="el-button is-white" onClick={() => this.updatePage()}>もっと見る</a>
              )
            }
          })()}
        </div>
      )
    }
  }
}

const mapStateToProps = (state) => {
  return {
    questions: state.questions,
    accessToken: state.accessToken,
    pager: state.pager
  }
}

export default connect(mapStateToProps)(Questions);