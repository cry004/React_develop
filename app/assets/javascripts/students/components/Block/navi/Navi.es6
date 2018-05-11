import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'
import _ from 'lodash'

import { Tab } from '../../Element/tab/Tab.es6'
import { Subject } from '../../Element/subject/Subject.es6'
import { RankingMenu } from '../../Element/ranking_menu/RankingMenu.es6'

import { requestCourses } from '../../../actions/courses.es6'
import { updateCurrentRankingTerm } from '../../../actions/rankings.es6'
import { updateCurrentRankingClassroomTerm } from '../../../actions/rankingsClassroom.es6'
import { updateCurrentCource,
  requestVideos } from '../../../actions/videos.es6'

export class Navi extends Component {
  constructor(props) {
    super(props)
  }
  componentDidMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestCourses(accessToken.accessToken))
  }
  linkOtherPage(url) {
    window.location.hash = url
  }
  isCurrentPage(urls) {
    const { locationHash } = this.props
    const matchUrl = _.filter(urls, (url) => {
      return url === locationHash.current
    })
    if (matchUrl.length > 0) {
      return true
    }
    return false
  }
  changeSubject(year, subject) {
    const { accessToken, locationHash, dispatch } = this.props
    dispatch(requestVideos(accessToken.accessToken, year, subject))
    dispatch(updateCurrentCource(year, subject))

    if (locationHash !== '/videos') {
      window.location.hash = '/videos'
    }
  }
  isCurrentSubject(subject) {
    const { locationHash, videos } = this.props
    if ( locationHash.current === '/videos' && videos.currentSubject === subject) {
      return true
    }
    return false
  }
  linkMemberPageOrLp() {
    const { isInternalMember } = this.props
    if (isInternalMember === true) {
      window.location.hash = '/teacher'
    } else {
      window.open().location.href='http://www.kobekyo.com/'
    }
  }
  onClickRanking(category, term) {
    const { dispatch } = this.props
    if (category === 'personal') {
      dispatch(updateCurrentRankingTerm(term))
      window.location.hash = `/ranking?period_type=${term}`
    } else {
      dispatch(updateCurrentRankingClassroomTerm(term))
      window.location.hash = `/ranking_classroom?period_type=${term}`
    }
  }

  render() {
    const { courses, locationHash, scroll, dispatch } = this.props
    return (
      <div className="bl-navi" style={{left: scroll.left}}>
        <div className="bl-tab"> 
          <Tab text="学習状況" 
            clickFunc={this.linkOtherPage.bind(this, '/learning_progresses')}
            isActive={this.isCurrentPage(['/learning_progresses'])}
            />
          <Subject text="英語" 
            isActive={this.isCurrentSubject('english')}
            subject="english"
            changeSubject={this.changeSubject.bind(this)}
            courses={courses} />
          <Subject text="数学" 
            isActive={this.isCurrentSubject('mathematics')}
            subject="mathematics"
            changeSubject={this.changeSubject.bind(this)}
            courses={courses} />
          <Subject text="理科" 
            isActive={this.isCurrentSubject('science')}
            subject="science"
            changeSubject={this.changeSubject.bind(this)}
            courses={courses} />
          <Subject text="社会" 
            isActive={this.isCurrentSubject('social_studies')}
            subject="social_studies"
            changeSubject={this.changeSubject.bind(this)}
            courses={courses} />
          <Subject text="国語" 
            isActive={this.isCurrentSubject('japanese')}
            subject="japanese"
            changeSubject={this.changeSubject.bind(this)}
            courses={courses} />
          <Tab text="ブックマーク" 
            clickFunc={this.linkOtherPage.bind(this, '/bookmark')}
            isActive={this.isCurrentPage(['/bookmark'])} />
          <Tab text="視聴履歴" 
            clickFunc={this.linkOtherPage.bind(this, '/history')} 
            isActive={this.isCurrentPage(['/history'])}/>
          <Tab text="添削指導" 
            clickFunc={this.linkOtherPage.bind(this, '/questions')}
            isActive={this.isCurrentPage(['/questions'])} />
          <Tab text="StudyPics" 
            clickFunc={this.linkOtherPage.bind(this, '/studypics')}
            isActive={this.isCurrentPage(['/studypics'])} />
          <RankingMenu isActive={this.isCurrentPage(['/ranking'])}
            onClickRanking={this.onClickRanking.bind(this)}
            dispatch={dispatch} />
          <Tab text="トライ会員" 
            clickFunc={this.linkMemberPageOrLp.bind(this)}
            isActive={this.isCurrentPage(['/teacher', '/jiritsu'])} />
        </div>
      </div>
    )
  }
}