import React, { Component } from 'react'
import classNames from 'classnames'
import { createMarkup } from '../../util/createMarkup.es6'
import { separateByThreeDigits } from '../../util/string.es6'

export class Card extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { video, selectVideo } = this.props
    const subjectClass = `card-subject u-color-${video.title.subject_key}`
    return(
      <div className="card u-clearfix" onClick={selectVideo.bind(this, video.video_id)}>
        {/* 次回リリース<a className="card-delete" onClick={(e) => {deleteVideo(e, video.video_id)}}>
        </a>*/}
        <div className="u-left">
          <div className="el-video">
            <div className="el-video-image">
              <img src={video.thumbnail_url} />
              {(() => {
                if (video.watched_count > 0) {
                  return (
                    <p className="el-watched">{separateByThreeDigits(video.watched_count)}回視聴済み</p>
                  )
                }
              })()}
              <p className="el-video-image-time">{video.duration.text}</p>
            </div>
          </div>
        </div>
        <div className="u-left">
          <p className={subjectClass}>
            {video.title.school_name}{video.title.subject_name} {video.title.subject_type} {video.title.subject_detail_name}
          </p>
          <p className="card-name" dangerouslySetInnerHTML={createMarkup(video.name)} />
          <p className="card-subname" dangerouslySetInnerHTML={createMarkup(video.subname)} />
          <p className="card-watch">
            {video.watched_on}に視聴
          </p>
        </div>
      </div>
    )
  }
}