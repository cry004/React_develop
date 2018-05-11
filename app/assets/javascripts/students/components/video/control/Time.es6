import React, { Component } from 'react' 

import { pauseVideo } from '../../../actions/video.es6'

export class Time extends Component {
  constructor(props) {
    super(props)
  }

  componentDidUpdate() {
    const { video, updateCurrentPlayTime, dispatch } = this.props
    if(parseInt(video.currentTime, 10) === parseInt(video.duration.seconds, 10) && video.isPaused === false) {
      const { videoDom } = this.props
      dispatch(pauseVideo())
      videoDom.pause()
      updateCurrentPlayTime()
    }
  }

  convertToMinutes(seconds) {
    let min = (`00${Math.floor(seconds / 60)}`).slice(-2) //２桁表示
    let sec = (`00${Math.floor(seconds % 60)}`).slice(-2) //２桁表示
    return `${min}:${sec}`
  }

  render() {
    const { video } = this.props
    return(
      <p className="video-control-time u-left">{this.convertToMinutes(video.currentTime)} / {video.durationTime}</p>
    )
  }
}