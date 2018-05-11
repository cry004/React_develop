import React, { Component } from 'react' 
import classNames from 'classnames'

import { playVideo,
  pauseVideo,
  updateIsShowOverlay,
  updateCurrentTime,
  updatePlayStartTime,
  updateClickPrev,
  updateClickNext,
  clickPlayAndPositionBar } from '../../actions/video.es6'

export class Move extends Component {
  constructor(props) {
    super(props)
  }

  playOrPause(e) {
    e.stopPropagation()
    const { video, videoDom, updateCurrentPlayTime, accessToken, dispatch } = this.props
    let time = video.currentTime
    if (video.isPaused === true) {
      if (parseInt(video.currentTime, 10) === parseInt(video.duration, 10)) {
        videoDom.currentTime = 0
        dispatch(updateCurrentTime(0))
      }
      videoDom.play()
      dispatch(playVideo())
      dispatch(clickPlayAndPositionBar(accessToken.accessToken, video.id, video.currentTime))
      dispatch(updatePlayStartTime(videoDom.currentTime))
      dispatch(updateIsShowOverlay(false))
    } else {
      videoDom.pause()
      dispatch(pauseVideo())
      updateCurrentPlayTime()
    }
  }

  nextPosition(e) {
    e.stopPropagation()
    const { video, videoDom, updateCurrentPlayTime, dispatch } = this.props
    videoDom.currentTime += 10
    if (video.isPaused === false) {
      dispatch(updateIsShowOverlay(false))
      updateCurrentPlayTime()
      dispatch(updatePlayStartTime(videoDom.currentTime))
    }
  }

  prevPosition(e) {
    e.stopPropagation()
    const { video, videoDom, updateCurrentPlayTime, dispatch } = this.props
    videoDom.currentTime -= 10
    if (video.isPaused === false) {
      dispatch(updateIsShowOverlay(false))
      updateCurrentPlayTime()
      dispatch(updatePlayStartTime(videoDom.currentTime))
    }
  }

  closeOverlay() {
    const { dispatch } = this.props
    dispatch(updateIsShowOverlay(false))
  }

  render() {
    const { video } = this.props
    const playButtonClass = classNames('video-move-play', {'is-paused': video.isPaused === false })

    return(
      <div className="video-move" onClick={() => this.closeOverlay()}>
        <a className="video-move-prev" onClick={(e) => this.prevPosition(e)}></a>
        <a className={playButtonClass} onClick={(e) => this.playOrPause(e)}></a>
        <a className="video-move-next" onClick={(e) => this.nextPosition(e)}></a>
      </div>
    )
  }
}