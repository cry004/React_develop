import React, { Component } from 'react' 
import classNames from 'classnames'

import { updateVolume,
  updateIsMute } from '../../../actions/video.es6'

export class Volume extends Component {
  constructor(props) {
    super(props)
  }

  toggeleMute() {
    const { video, videoDom, dispatch } = this.props  
    if( videoDom.volume > 0 ) {
      videoDom.volume = 0
      dispatch(updateIsMute(true));
    } else {
      videoDom.volume = video.volume;
      dispatch(updateIsMute(false));
    }
  }

  clickVolumeBar(event) {
    const { video, videoDom, dispatch } = this.props
    const CLICKWIDTH = event.nativeEvent.offsetX
    const BARWIDTH = this.volumeDom.offsetWidth
    let nextVolume = CLICKWIDTH / BARWIDTH
    videoDom.volume = nextVolume
    dispatch(updateVolume(nextVolume))
  }

  onMouseDown() {
    console.log("mousedown")
  }


  render() {
    const { video, videoDom } = this.props
    const volumePositionStyle = videoDom ? `${videoDom.volume * 100}%` : 0;
    const volumeIconClass = classNames('video-control-volume-icon', {'is-unmute': videoDom && (videoDom.volume > 0)})
    return(
      <div className="u-left video-control-volume">
        <div className={volumeIconClass} onClick={() => this.toggeleMute()}></div>
        <div className="video-control-volume-bar">
          <div className="video-control-positionbar" onClick={(event) => this.clickVolumeBar(event)} ref={(positionbar) => this.volumeDom = positionbar} onMouseDown={(e) => this.onMouseDown(e)}>
            <span style={{width: volumePositionStyle}}></span>
          </div> 
        </div>
      </div>
    )
  }
}