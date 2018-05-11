import React, { Component } from 'react' 
import classNames from 'classnames'
import { clickPlayAndPositionBar,
  updatePlayStartTime } from '../../actions/video.es6'


export class Chapters extends Component {
  constructor(props) {
    super(props)
  }

  selectChapter(e, i) {
    const { video, accessToken, updateCurrentPlayTime, videoDom, dispatch } = this.props
    videoDom.currentTime = video.chapters[i].position

    if (video.isPaused === false) {
      updateCurrentPlayTime()
      dispatch(clickPlayAndPositionBar(accessToken.accessToken, video.id, parseInt(video.chapters[i].position, 10)))
    }
    dispatch(updatePlayStartTime(videoDom.currentTime))
  }

  render() {
    const { video } = this.props
    return(
      <div className="chapters u-clearfix">
        {video.chapters.map((chapter, i) =>
          <p key={i} className={classNames('chapter', {'is-current': (i + 1) === video.currentChapter})} onClick={(e) => this.selectChapter(e, i)}>{chapter.title}
          </p>
        )}
      </div>
    )
  }
}