import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { MyStatus } from '../Block/my_status/MyStatus.es6'
import { Video } from '../Element/video/Video.es6'
import { Tab } from '../Element/tab/Tab.es6'

import { updateVideoId } from '../../actions/video.es6'
import { requestTeacherRecommends,
  requestTeacherVideos,
  requestTeacherDetail,
  updateCurrentTeacherId,
  initTeacherRecommends　} from '../../actions/teacher.es6'
import { updateCurrentPage } from '../../actions/pager.es6'
import { requestLearningProgresses } from '../../actions/learningProgresses.es6'
import { isShowLoading } from '../../actions/loading.es6'

class Teacher extends Component {

  constructor(props) {
    super(props)
    //スクロールイベント頻発を防ぐためsetTimeout
    this.setTimoutId = null
  }
  componentWillMount() {
    const { teacher, accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(initTeacherRecommends())
    dispatch(requestLearningProgresses(accessToken.accessToken))
    dispatch(updateCurrentPage(1))
    if (!!teacher.currentId) {
      dispatch(requestTeacherRecommends(accessToken.accessToken, 1, 20, false))
      dispatch(requestTeacherDetail(accessToken.accessToken, teacher.currentId))
    } else {
      dispatch(requestTeacherRecommends(accessToken.accessToken, 1, 20, true))
    }
  }
  componentDidMount() {
    const { teacher, accessToken, dispatch } = this.props
    this.menuDom.addEventListener("scroll", this.requestNextPage.bind(this))
    // if (teacher.recommendations.length > 0) {
    //   let id = teacher.recommendations[teacher.currentRecommend]['id']
    //   dispatch(requestTeacherVideos(accessToken.accessToken, id))
    // }
  }
  componentWillReceiveProps(nextProps) {
    const { teacher, accessToken, dispatch } = this.props
    if (nextProps.pager.isLastPage === true) {
      this.menuDom.removeEventListener("scroll", this.requestNextPage)
    }
    if (teacher.currentId !== nextProps.teacher.currentId) {
      dispatch(requestTeacherDetail(accessToken.accessToken, nextProps.teacher.currentId))
    }
    if (teacher.isFetching === true && nextProps.teacher.isFetching === false) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { teacher, dispatch } = this.props
    dispatch(updateCurrentTeacherId(null))
    dispatch(isShowLoading(false))
  }
  requestNextPage() {
    const { accessToken, pager, teacher, dispatch } = this.props
    if (pager.isLastPage || teacher.isFetching === true) {
      return false;
    }
    const MENU_HEIGHT = this.menuDom.clientHeight
    const THRESHOLD = 100 //一番下から${THRESHOLD}px上までスクロールされた次を読み込む
    let self = this
    if (this.setTimeoutId) {
      return false
    }
    this.setTimeoutId = setTimeout(() => {
      if (self.menuDom.scrollTop + MENU_HEIGHT + THRESHOLD > self.menuDom.scrollHeight) {
        dispatch(requestTeacherRecommends(accessToken.accessToken , pager.currentPage + 1))
      }
      self.setTimeoutId = null
    }, 100)
  }

  linkOtherPage(url) {
    window.location.hash = url
  }
  selectVideo(videoId) {
    const { dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  updateCurrentRecommend(id) {
    const { teacher, accessToken, dispatch } = this.props
    dispatch(updateCurrentTeacherId(id))
    // if (teacher.recommendations.length > 0) {
    //   let id = teacher.recommendations[recommentNum]['id']
    //   dispatch(requestTeacherVideos(accessToken.accessToken, id))
    // }
    dispatch(requestTeacherDetail(accessToken.accessToken, id))
  }
  isCurrentPage(url) {
    const { locationHash } = this.props
    if (locationHash.current === url) {
      return true
    }
    return false
  }
  isUnreadClass(unread) {
    return unread == true ? "is-unread" : ""
  }
  render() {
    const { learningProgresses, teacher, dispatch } = this.props
    const noContentClass = classNames('el-text-nocontent', { 'u-hidden' : teacher.recommendations.length > 0 })
    const contentClass = classNames('container u-clearfix', { 'u-hidden' : teacher.recommendations.length < 1})

    return (
      <div className="page-teacher">
        <MyStatus learningProgresses={learningProgresses} />
        <div className="bl-tab">
          <Tab text="マンツーマンコース"
            clickFunc={this.linkOtherPage.bind(this, '/teacher')}
            isActive={this.isCurrentPage('/teacher')} />
          <Tab text="Myトライコース"
            clickFunc={this.linkOtherPage.bind(this, '/jiritsu')}
            isActive={this.isCurrentPage('/jiritsu')} />
        </div>
        <p className={noContentClass}>まだ先生からの映像授業がありません。</p>
        <div className={contentClass}>
          <div>
            <ul className="el-submenu is-teacher u-left" ref={(menu) => this.menuDom = menu}>
              {teacher.recommendations.map((recommendation, i) =>
                <li key={i} className={this.isUnreadClass(recommendation.unread)} onClick={()=> this.updateCurrentRecommend(recommendation.recommendation_id)}>
                  <p className="el-submenu-title">{recommendation.teacher_name}からの授業</p>
                  <p className="el-submenu-date">{recommendation.date}</p>
                </li>
              )}
            </ul>
            <ul className="container-main u-left">
              <li className="container-main-list">
                <p className="date">{teacher.currentRecommend.date}</p>
                <div className="teacher u-clearfix">
                  <div className="teacher-image u-left">
                  </div>
                  {(() => {
                    if (!!teacher.currentRecommend.message) {
                      return (
                        <p className="teacher-comment u-left">{teacher.currentRecommend.message}</p>
                      )
                    }
                  })()}
                </div>
                <ul className="cards u-clearfix">
                  {teacher.currentRecommend.videos.map((video, j) =>
                    <li className="card u-left" key={j} onClick={() => this.selectVideo(video.video_id)}>
                      <Video video={video} isSubject="true" />
                    </li>
                  )}
                </ul>
              </li>
            </ul>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    teacher: state.teacher,
    accessToken: state.accessToken,
    pager: state.pager,
    scroll: state.scroll,
    locationHash: state.locationHash,
    learningProgresses: state.learningProgresses
  }
}

export default connect(mapStateToProps)(Teacher);
