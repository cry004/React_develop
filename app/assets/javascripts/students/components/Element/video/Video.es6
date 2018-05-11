import React, { Component } from 'react'
import { createMarkup } from '../../../util/createMarkup.es6'
import { separateByThreeDigits } from '../../../util/string.es6'

export class Video extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { video, isSubject } = this.props
    const subjectClassName = `el-video-subject u-color-${video.title.subject_key}`
    return(
      <div className="el-video">
        <div className="el-video-image">
          <img src={video.thumbnail_url} />
          {(() => {
            if (video.watched_count > 0) {
              return (
                <p className="el-watched">{separateByThreeDigits(video.watched_count)}回視聴済み</p>
              )
            } else if (video.locked_video === true) {
              return (
                <div className="el-video-image-locked"></div>
              )
            }
          })()}
          {video.video_type === 'review' &&
            <p className="el-video-type is-review">復習</p>
          }
          {video.video_type === 'preparation' &&
            <p className="el-video-type is-preparation">予習</p>
          }
          <p className="el-video-image-time">{video.duration.text}</p>
        </div>
        {isSubject === "true" &&
          <p className={subjectClassName}>{video.title.school_name}{video.title.subject_name} {video.title.subject_type} {video.title.subject_detail_name}</p>
        }
        <p className="el-video-name" dangerouslySetInnerHTML={createMarkup(video.name)} />
        <p className="el-video-subname" dangerouslySetInnerHTML={createMarkup(video.subname)} />
      </div>
    )
  }
}