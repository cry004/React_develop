import React, { Component } from 'react' 

import { updateRateHigh } from '../../../actions/video.es6'

export class Speed extends Component {
  constructor(props) {
    super(props)
  }

  toggleSpeed() {
    const { isHighRate, videoDom, isAndroid, updateCurrentPlayTime, dispatch } = this.props
    if (isHighRate === true) {
      dispatch(updateRateHigh(false))
      if (isAndroid === false) {
        videoDom.playbackRate = 1.0
      }
    } else {
      dispatch(updateRateHigh(true))
      if ( isAndroid === false) {
        videoDom.playbackRate = 1.4
      }
    }
  }

  render() {
    const { isHighRate } = this.props
    const speedRateText = isHighRate === true ? '1.4 x' : '1.0 x'
    return(
      <a className="video-control-speed u-left" onClick={() => this.toggleSpeed()}>{speedRateText}</a>
    )
  }
}