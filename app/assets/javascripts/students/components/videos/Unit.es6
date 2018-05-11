import React, { Component } from 'react'
import { Video } from '../Element/video/Video.es6'
import { createMarkup } from '../../util/createMarkup.es6'

export class Unit extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { unit, selectVideo } = this.props
    return(
      <div>
        <h2 className="videos-title" dangerouslySetInnerHTML={createMarkup(unit.title)} />
        <div className="cards">
          {unit.videos.map((video, j) =>
            <div className="el-card" key={j} onClick={selectVideo.bind(this, video.video_id)}>
              <Video video={video} isSubject="false" />
            </div>
          )}
        </div>
      </div>
    )
  }
}