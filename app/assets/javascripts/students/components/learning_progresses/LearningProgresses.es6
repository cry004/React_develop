import React, { Component } from 'react'
import { connect } from 'react-redux'

import { MyStatus } from '../Block/my_status/MyStatus.es6'
import { Subjects } from './Subjects.es6'
import { ListArea } from './ListArea/ListArea.es6'
import { ListAreaRecent } from './ListArea/ListAreaRecent.es6'

import { showPopup, hidePopup } from '../../actions/popup.es6'
import { requestUser, hideSchoolbookDialogs } from '../../actions/user.es6'
import { requestLearningProgresses,
  updateLearningProgressSubject } from '../../actions/learningProgresses.es6'
import { isShowLoading } from '../../actions/loading.es6'

class LearningProgresses extends Component {

  constructor(props) {
    super(props)
    this.state = {
      _currentTab: 'recent'
    }
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(hidePopup())
    dispatch(requestLearningProgresses(accessToken.accessToken))
  }
  componentDidMount() {
    const { user, dispatch } = this.props
    if (user.firstLogin === true) {
      dispatch(showPopup('textbook'))
    }
  }
  componentWillReceiveProps(nextProps) {
    const { user, learningProgresses, dispatch } = this.props
    if (learningProgresses.isFetching === true && nextProps.learningProgresses.isFetching === false) {
      dispatch(isShowLoading(false))
    }
    if (user.firstLogin === false && nextProps.user.firstLogin === true) {
      dispatch(showPopup('textbook'))
    }
  }
  componentWillUnmount() {
    const { accessToken, dispatch } = this.props
    dispatch(updateLearningProgressSubject('recent'))
    dispatch(isShowLoading(false))
  }
  changeSubject(tabname) {
    this.setState({
      _currentTab: tabname
    })
  }
  isCurrentPage(url) {
    if (this.state._currentTab === url) {
      return true
    }
    return false
  }

  render() {
    const { courses, accessToken, learningProgresses, dispatch } = this.props
    return (
      <div className="page-studystatus">
        <MyStatus learningProgresses={learningProgresses} />
        <Subjects changeSubject={this.changeSubject.bind(this)} isCurrentPage={this.isCurrentPage.bind(this)} />
        {(() => {
          if(this.state._currentTab === 'recent') {
            return (
              <ListAreaRecent accessToken={accessToken} lastLearningSubjects={learningProgresses.lastLearningSubjects} dispatch={dispatch} />
            )
          } else {
            return (
              <ListArea courses={courses} currentTab={this.state._currentTab} accessToken={accessToken} dispatch={dispatch} />
            )
          }
        })()}
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    user: state.user,
    accessToken: state.accessToken,
    learningProgresses: state.learningProgresses,
    courses: state.courses
  }
}

export default connect(mapStateToProps)(LearningProgresses);
