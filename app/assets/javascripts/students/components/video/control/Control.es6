import React, { Component } from 'react' 

import { Position } from './Position.es6'
import { Volume } from './Volume.es6'
import { Time } from './Time.es6'
import { Speed } from './Speed.es6'
import { Enlarge } from './Enlarge.es6'

export class Control extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { video, videoDom, useragent, updateCurrentPlayTime, accessToken, dispatch } = this.props
    return(
      <div className="video-control">
        <Position video={video} videoDom={videoDom} accessToken={accessToken} dispatch={dispatch} updateCurrentPlayTime={updateCurrentPlayTime} />
        <div className="u-clearfix">
          {useragent.isIOS === false &&
            <Volume video={video} videoDom={videoDom} dispatch={dispatch} />
          }
          <Time video={video} videoDom={videoDom} updateCurrentPlayTime={updateCurrentPlayTime} dispatch={dispatch} />
          <div className="u-right u-clearfix">
            <Speed isHighRate={video.isHighRate} videoDom={videoDom} isAndroid={useragent.isAndroid} updateCurrentPlayTime={updateCurrentPlayTime} dispatch={dispatch} />
            <Enlarge isEnlarged={video.isEnlarged} dispatch={dispatch} />
          </div>
        </div>
      </div>
    )
  }
}