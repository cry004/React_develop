import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'
import classNames from 'classnames'

import { Chapters } from './Chapters.es6'
import { VideoInfo } from './VideoInfo.es6'
import { Move } from './Move.es6'
import { Control } from './control/Control.es6'

import { Answer } from './Answer.es6'
import { Commentary } from './Commentary.es6'
import { Textbook } from './Textbook.es6'
import { Videos } from './videos/Videos.es6'
import { Tab } from '../Element/tab/Tab.es6'
import { isShowLoading } from '../../actions/loading.es6'
import { showPopup } from '../../actions/popup.es6'

import { pauseVideo,
  updateCurrentTime,
  updateCurrentChapter,
  updateIsShowOverlay,
  updateIsEnlarged,
  updatePlayTime,
  updatePlayStartTime,
  requestVideo,
  postPlayTime,
  addBookmark,
  deleteBookmark,
  updateVideoId,
  updateVideoCurrentTab,
  updateIsVideoLoaded,
  updateRateHigh,
  textImageLoaded
} from '../../actions/video.es6'
import { createQuestionByVideo,
  updateCreateQuestionStatus } from '../../actions/createQuestion.es6'


class Video extends Component {

  constructor(props) {
    super(props)
    this.state = {
      isVideoQuestion: false
    }
  }
  componentWillMount() {
    const { video, accessToken, locationHash, createQuestion, dispatch } = this.props
    dispatch(pauseVideo())
    dispatch(updateVideoCurrentTab('commentary'))
    dispatch(updateIsVideoLoaded(false))
    dispatch(isShowLoading(true))
    dispatch(updatePlayStartTime(0))
    dispatch(updateIsEnlarged(false))
    dispatch(updateRateHigh(false))
    dispatch(requestVideo(accessToken.accessToken, video.nextId))
    dispatch(updateIsShowOverlay(false))
    dispatch(textImageLoaded(false))
    // 「映像授業から質問作成」からこの画面に戻ってきた時は初期化しない
    if (locationHash.prev !== '/create_question' && createQuestion.questionType !== "video") {
      dispatch(updateCurrentTime(0))
      dispatch(updateCurrentChapter(1))
      dispatch(updatePlayTime(0))
    }
  }
  componentDidMount() {
    const { useragent, video, dispatch } = this.props
    const videoDom = this.videoDom
    videoDom.setAttribute('webkit-playsinline', true)
    videoDom.setAttribute('playsinline', true)
    if (useragent.isIOS === false) {
      videoDom.addEventListener('loadeddata', () => {
        dispatch(updateIsVideoLoaded(true))
        dispatch(updateIsShowOverlay(true))
      })
    } else {
      dispatch(updateIsShowOverlay(true))
      dispatch(updateIsVideoLoaded(true))
    }
    videoDom.addEventListener('loadeddata', () => {
      videoDom.currentTime = video.currentTime
      dispatch(updatePlayStartTime(video.currentTime))
    })
    window.addEventListener('beforeunload', () => {
      this.sendPlayTime()
    })
  }
  componentWillReceiveProps(nextProps) {
    const { accessToken, video, dispatch } = this.props
    if (video.nextId !== nextProps.video.nextId) {
      dispatch(requestVideo(accessToken.accessToken, nextProps.video.nextId))
    }
    if (video.isFetching === true && nextProps.video.isFetching === false) {
      // 授業テキストがない場合や前回と同じ(=ロード済み)ならローデイングをここで外す
      if (!nextProps.video.checktestUrl || video.checktestUrl === nextProps.video.checktestUrl) {
        dispatch(textImageLoaded(true))
      }
    }
    if (video.isImageLoaded === false && nextProps.video.isImageLoaded === true) {
      dispatch(isShowLoading(false))
    }
    // fixme: sagaとかにうつす(currentTimeとかと一緒にリファクタリングする)
    if (video.currentTime !== nextProps.video.currentTime) {
      if (nextProps.video.currentTime === 0) {
        this.updateChapter(0)
        return false
      }
      switch(nextProps.video.currentChapter) {
        case 1:
          if (nextProps.video.chapters[video.currentChapter] && nextProps.video.chapters[video.currentChapter].position <= nextProps.video.currentTime) {
            this.updateChapter(nextProps.video.currentTime)
          }
          break
        case nextProps.video.chapters.length:
          if (nextProps.video.chapters[video.currentChapter - 1] && nextProps.video.chapters[video.currentChapter - 1].position > nextProps.video.currentTime) {
            this.updateChapter(nextProps.video.currentTime)
          }
          break
        default:
          if (nextProps.video.chapters[video.currentChapter] && nextProps.video.chapters[video.currentChapter].position <= nextProps.video.currentTime || nextProps.video.chapters[video.currentChapter - 1] && nextProps.video.chapters[video.currentChapter - 1].position > nextProps.video.currentTime) {
            this.updateChapter(nextProps.video.currentTime)
          }
          break
      }
    }
  }
  componentDidUpdate(prevProps, prevState) {
    if (prevState.isVideoQuestion === false && this.state.isVideoQuestion === true) {
      const { video, accessToken, dispatch } = this.props
      if (video.isPaused === false) {
        this.updateCurrentPlayTime()
      }
      dispatch(updateCreateQuestionStatus("initial"))
      dispatch(createQuestionByVideo(accessToken.accessToken, video.id, parseInt(video.currentTime, 10)))
    }
  }
  componentWillUnmount() {
    if (this.state.isVideoQuestion === false) {
      this.sendPlayTime()
    }
  }

  updateChapter(currentTime) {
    const { video, dispatch } = this.props
    let current = 0
    video.chapters.forEach((chapter, index) => {
      if (chapter.position <= currentTime) {
        current = index + 1
      }
    })
    dispatch(updateCurrentChapter(current))
  }
  updateVideoQuestionFlag() {
    const { video, user, dispatch } = this.props
    if (user.isInternalMember === false && video.lockedVideo === true) {
      dispatch(showPopup('question-for-internal-member'))
      return false
    }
    this.setState({
      isVideoQuestion: true
    })
  }
  updateCurrentPlayTime() {
    const { video, useragent, dispatch } = this.props
    const DENOMINATOR = useragent.isAndroid && video.isHighRate ? 1.4 : 1
    let time = (video.currentTime - video.playStartTime) / DENOMINATOR + video.playTime === 0 ? 0 : ((video.currentTime - video.playStartTime)/ DENOMINATOR + video.playTime) + 1
    dispatch(updatePlayTime((video.currentTime - video.playStartTime)/ DENOMINATOR + video.playTime + 1))
  }
  sendPlayTime() {
    const { video, accessToken, useragent, dispatch } = this.props
    const DENOMINATOR = useragent.isAndroid && video.isHighRate ? 1.4 : 1
    const totalPlayTime = video.isPaused === true ? video.playTime : (video.currentTime - video.playStartTime) / DENOMINATOR + video.playTime
    if (totalPlayTime > 0) {
      dispatch(postPlayTime(accessToken.accessToken, video.id, parseInt(totalPlayTime + 1, 10)))
    }
    dispatch(pauseVideo())
    dispatch(updatePlayTime(0))
    dispatch(updateCurrentTime(0))
    dispatch(updatePlayStartTime(0))
    if (useragent.isIOS === false) {
      dispatch(updateIsShowOverlay(false))
    } else {
      dispatch(updateIsShowOverlay(true))
    }
  }
  showOverlay() {
    const { dispatch } = this.props
    dispatch(updateIsShowOverlay(true))
  }
  onTimeUpdate() {
    const { dispatch, video } = this.props
    const videoDomCurrentTime = parseInt(this.videoDom.currentTime, 10)
    if (video.currentTime !== videoDomCurrentTime) {
      dispatch(updateCurrentTime(videoDomCurrentTime))
    }
  }
  toggleBookmark() {
    const { accessToken, video, dispatch } = this.props
    if (video.isBookmarked === true) {
      dispatch(deleteBookmark(accessToken.accessToken, video.id))
    } else {
      dispatch(addBookmark(accessToken.accessToken, video.id))
    }
  }
  updateTab(tabName) {
    const { dispatch } = this.props
    dispatch(updateVideoCurrentTab(tabName))
  }
  isCurrentTab(tabName) {
    const { video } = this.props
    if (video.currentTab === tabName) {
      return true
    } else {
      return false
    }
  }
  watchOtherVideo(id, type, index) {
    const { video, accessToken, dispatch } = this.props
    if (type === 'next') {
      ga('send', 'event', `${index}つ先の授業`, 'click', `pc_eizojugyo_detail_${index}ahead`, 1)
    } else {
      ga('send', 'event', `${index}つ前の授業`, 'click', `pc_eizojugyo_detail_${index}before`, 1)
    }
    dispatch(updateVideoId(id))
    if (video.lockedVideo === false) {
      dispatch(pauseVideo())
      this.sendPlayTime()
    }
    dispatch(updateRateHigh(false))
    this.forceUpdate()
  }
  render() {
    const { video, createQuestion, accessToken, useragent, dispatch } = this.props
    const videoContainerClass = classNames('video', {'is-enlarged': video.isEnlarged})
    const videoClass = classNames({'is-visible': video.isVideoLoaded === true})
    const layerStyle = classNames({'is-visible': video.isShowOverlay === true})
    const contentClass = `content tab-${video.currentTab}`
    const externalStyle = {
      backgroundImage: `url(${video.thumbnailUrl})`
    }
    const videoSectionContainer = classNames('video-section u-left', {'is-locked': video.lockedVideo === true})
    const lockedContainerClass = classNames('video-locked', {'u-hidden': video.lockedVideo === false})
    const videoWrapperClass = classNames({'u-hidden': video.lockedVideo === true})
    const videoUrl = (useragent.isAndroid === true && video.isHighRate === true) ? video.doubleSpeedVideoUrl : video.videoUrl
    return (
      <div className="page-video u-clearfix">
        <div className={videoSectionContainer}>
          <div className={videoContainerClass}>
            <div className={lockedContainerClass} style={externalStyle}>
              <div className="video-locked-container">
                <div>
                  <p className="video-locked-heading">この授業はトライ会員専用の授業です。</p>
                  <p className="video-locked-description">
                  トライで完全1対1の無料体験授業を受けてみませんか？
                    <br/>
                    体験中はトライイットの全ての授業を視聴することができます。
                  </p>
                  <a className="el-button color-transparent" href="http://www.kobekyo.com/" target="_blank">無料体験授業の申し込みはこちら</a>
                </div>
              </div>
            </div>
            <div className={videoWrapperClass}>
              <video className={videoClass} type="video/mp4" controls={false} preload="auto" src={videoUrl} ref={(video) => this.videoDom = video} onTimeUpdate={() => this.onTimeUpdate()}>
              </video>
              <div className={layerStyle}>
                <Move video={video} videoDom={this.videoDom} dispatch={dispatch} updateCurrentPlayTime={this.updateCurrentPlayTime.bind(this)} accessToken={accessToken} />
                <div className="video-overlay" onClick={() => this.showOverlay()}>
                </div>
                <Control video={video} videoDom={this.videoDom} useragent={useragent} updateCurrentPlayTime={this.updateCurrentPlayTime.bind(this)} dispatch={dispatch} accessToken={accessToken} />
              </div>
            </div>
          </div>
          <VideoInfo video={video} toggleBookmark={this.toggleBookmark.bind(this)} updateVideoQuestionFlag={this.updateVideoQuestionFlag.bind(this) } />
          <Chapters video={video} videoDom={this.videoDom} accessToken={accessToken} updateCurrentPlayTime={this.updateCurrentPlayTime.bind(this)} dispatch={dispatch} />
        </div>
        <div className="content-section u-left">
          <div className="bl-tab">
            {!!video.kaisetuWebUrl &&
              <Tab text="解説"
                clickFunc={this.updateTab.bind(this, 'commentary')} isActive={this.isCurrentTab('commentary')}/>
            }
            {!!video.checktestUrl &&
              <Tab text="テキスト" clickFunc={this.updateTab.bind(this, 'textbook')} isActive={this.isCurrentTab('textbook')} />
            }
            {!!video.answerUrl &&
              <Tab text="解答" clickFunc={this.updateTab.bind(this, 'answer')} isActive={this.isCurrentTab('answer')}/>
            }
            <Tab text="前後の授業"
              clickFunc={this.updateTab.bind(this, 'videos')} isActive={this.isCurrentTab('videos')}/>
          </div>
          <div className={contentClass}>
            {!!video.kaisetuWebUrl &&
              <Commentary kaisetuWebUrl={video.kaisetuWebUrl} video={video} dispatch={dispatch} />
            }
            {!!video.checktestUrl &&
              <Textbook checktestUrl={video.checktestUrl} video={video} dispatch={dispatch} />
            }
            {!!video.answerUrl &&
              <Answer answerUrl={video.answerUrl} />
            }
            <Videos accessToken={accessToken} nextVideos={video.nextVideos} previousVideos={video.previousVideos} watchOtherVideo={this.watchOtherVideo.bind(this)} />
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    user: state.user,
    video: state.video,
    useragent: state.useragent,
    accessToken: state.accessToken,
    locationHash: state.locationHash,
    createQuestion: state.createQuestion
  }
}

export default connect(mapStateToProps)(Video);
