import React, { Component } from 'react'

import { LessonText } from '../components/LessonText.es6'
import { CheckText } from '../components/CheckText.es6'
import { PracticeText } from '../components/PracticeText.es6'

export class Btns extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { editFlag, video, videoIndex, setYoutubeURL } = this.props
    let btnsDom
    if(!editFlag) {
      btnsDom = <div className="btns">
        <LessonText video={video} />
        <CheckText video={video} />
        <PracticeText video={video} />
        {(() => {
          if (video.youtube_url !== null && video.youtube_url !== undefined) {
            return <div className="btns-area">
                <h5 className="title movie">映像授業{videoIndex + 1}</h5>
                <input type="button" className="el-button size-mini" value="再生" onClick={setYoutubeURL.bind(this, video.youtube_url)} />
              </div>
          }
        })()}
        <p className="movie_name">
          {video.video_name}
        </p>
      </div>
    }
    return(
      <div>
        {btnsDom}
      </div>
    )
  }
}
