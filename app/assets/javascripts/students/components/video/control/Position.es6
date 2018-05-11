import React, { Component } from 'react' 
import { updatePlayStartTime,
  clickPlayAndPositionBar } from '../../../actions/video.es6'

export class Position extends Component {
  constructor(props) {
    super(props)
  }

  componentDidMount() {
    this.updatePositionBar()
  }

  clickPositionBar(event) {
    event.preventDefault()
    const { video, videoDom, updateCurrentPlayTime, accessToken, dispatch } = this.props
    const CLICKWIDTH = event.nativeEvent.offsetX
    const BARWIDTH = this.positionDom.offsetWidth
    let nextCurrentTime = CLICKWIDTH * video.duration.seconds / BARWIDTH
    videoDom.currentTime = nextCurrentTime
    if (video.isPaused === false) {
      updateCurrentPlayTime()
      dispatch(clickPlayAndPositionBar(accessToken.accessToken, video.id, parseInt(nextCurrentTime, 10)))
    }
    dispatch(updatePlayStartTime(videoDom.currentTime))
  }

  updatePositionBar() {
    let offsetLeft = this.positionDom.offsetLeft
    let offsetRight = this.positionDom.offsetRight
  }

  render() {
    const { video } = this.props
    const timePositionStyle = `${video.currentTime / video.duration.seconds * 100}%`
    return(
      <div className="video-control-position">
        <div className="video-control-positionbar" onClick={(event) => this.clickPositionBar(event)} ref={(positionbar) => this.positionDom = positionbar}>
          <span style={{width: timePositionStyle}}></span>
        </div>
      </div>
    )
  }
}