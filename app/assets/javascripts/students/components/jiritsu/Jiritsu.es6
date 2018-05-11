import React, { Component } from 'react'
import { connect } from 'react-redux'

import { MyStatus } from '../Block/my_status/MyStatus.es6'
import { Video } from '../Element/video/Video.es6'
import { Tab } from '../Element/tab/Tab.es6'

import { selectVideo } from '../../actions/video.es6'
import { requestJukuLearningsCurrent,
  requestJukuLearningsArchives } from '../../actions/jukuLearnings.es6'
import { requestLearningProgresses } from '../../actions/learningProgresses.es6'
import { initPager,
  updateCurrentPage } from '../../actions/pager.es6'
import { updateVideoId } from '../../actions/video.es6'
import { isShowLoading } from '../../actions/loading.es6'

class Jiritsu extends Component {

  constructor(props) {
    super(props)
    this.state = {
      _currentType: 'today'
    }
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(requestLearningProgresses(accessToken.accessToken))
    dispatch(requestJukuLearningsCurrent(accessToken.accessToken))
  }
  componentWillReceiveProps(nextProps) {
    const { jukuLearnings, dispatch } = this.props
    if (jukuLearnings.isFetching === true && nextProps.jukuLearnings.isFetching === false) {
      dispatch(isShowLoading(false))
    } else if (jukuLearnings.isFetching === false && nextProps.jukuLearnings.isFetching === true) {
      dispatch(isShowLoading(true))
    }   
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  selectVideo(videoId) {
    const { dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  linkOtherPage(url) {
    window.location.hash = url
  }
  isCurrentPage(url) {
    const { locationHash } = this.props
    if (locationHash.current === url) {
      return true
    }
    return false
  }
  showPast() {
    const { accessToken, dispatch } = this.props
    dispatch(updateCurrentPage(1))
    dispatch(requestJukuLearningsArchives(accessToken.accessToken, 1))
    this.setState({
      _currentType: 'past'
    })
  }
  updatePage() {
    const { pager, accessToken, dispatch } = this.props
    dispatch(requestJukuLearningsArchives(accessToken.accessToken , pager.currentPage + 1))
  }
  openPdf(e, pdfUrl) {
    e.stopPropagation()
    window.open(pdfUrl)
  }

  render() {
    const { learningProgresses, pager, scroll, jukuLearnings, dispatch } = this.props
    const noVideoText = this.state._currentType === 'past' ? '過去の授業はありません。' : '今日の授業はありません。'
    return (
      <div className="page-jiritsu">
        <MyStatus learningProgresses={learningProgresses} />
        <div className="bl-tab" style={{left: scroll.left}}>
          <Tab text="マンツーマンコース" 
            clickFunc={this.linkOtherPage.bind(this, '/teacher')} 
            isActive={this.isCurrentPage('/teacher')}
          />
          <Tab text="Myトライコース" 
            clickFunc={this.linkOtherPage.bind(this, '/jiritsu')} 
            isActive={this.isCurrentPage('/jiritsu')}
          />
        </div>
        <div className="container">
          {(() => {
            if(this.state._currentType === 'past') {
              return (
                <h1 className="heading">過去に学習報告された授業</h1>
              )
            }
          })()}
          
          {(() => {
            if (jukuLearnings.learnings.length < 1) {
              return (
                <p className="el-text-nocontent">{noVideoText}</p>
              )
            }　else {
              return (
                <ul>
                  {jukuLearnings.learnings.map((learning, i) =>
                    <li className="lessons" key={i}>
                      <p className="date">{learning.date} {learning.start_time} {learning.end_time}の授業</p>
                      <ul className="cards u-clearfix">
                        {learning.items.map((item, j) =>
                          <li className="el-card u-left" key={j} onClick={() => this.selectVideo(item.video_id)}>
                            <Video video={item} isSubject="true" />
                            <div className="button-wrapper">
                              {!!item.syutoku_answer_pdf_url &&
                                <a className="el-button-gray" onClick={(e) => this.openPdf(e, item.syutoku_answer_pdf_url)}>習得・習熟</a>
                              }
                              {!!item.ensyu_answer_pdf_url &&
                                <a className="el-button-gray" onClick={(e) => this.openPdf(e, item.ensyu_answer_pdf_url)}>演習</a>
                              }
                            </div>
                          </li>
                        )}
                      </ul>
                    </li>
                  )}
                </ul>
              )
            }
          })()}
          
          {(() => {
            if(this.state._currentType === 'today') {
              return (
                <a className="el-button size-large is-white" onClick={()=>this.showPast()}>過去の授業をみる</a>
              )
            } else if (pager.isLastPage === false) {
              return (
                <a className="el-button size-large is-white" onClick={()=>this.updatePage()}>もっとみる</a>
              )
            }
          })()}
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    jukuLearnings: state.jukuLearnings,
    pager: state.pager,
    accessToken: state.accessToken,
    scroll: state.scroll,
    locationHash: state.locationHash,
    learningProgresses: state.learningProgresses
  }
}

export default connect(mapStateToProps)(Jiritsu);