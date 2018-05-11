import React, { Component } from 'react'
import { createMarkup } from '../../../util/createMarkup.es6'
import { separateByThreeDigits } from '../../../util/string.es6'

export class Video extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { video, watchOtherVideo, type, index } = this.props
    return(
      <div className="videos-video u-clearfix" onClick={()=>watchOtherVideo(video.id, type, index)}>
        <div className="el-video u-left">
          <div className="el-video-image">
            <img src={video.thumbnail_url} />
              {(() => {
                if (video.current_student_watched_count > 0) {
                  return (
                    <p className="el-watched">{separateByThreeDigits(video.current_student_watched_count)}回視聴済み</p>
                  )
                } else if (video.locked_video === true) {
                  return (
                    <div className="el-video-image-locked"></div>
                  )
                }
              })()}
            <p className="el-video-image-time">{video.duration.text}</p>
          </div>
        </div>
        <div className="videos-video-text u-left">
          <p className="videos-video-title" dangerouslySetInnerHTML={createMarkup(video.name)} />
          <p className="videos-video-subtitle" dangerouslySetInnerHTML={createMarkup(video.subname)} />
        </div>
      </div>
    )
  }
}
