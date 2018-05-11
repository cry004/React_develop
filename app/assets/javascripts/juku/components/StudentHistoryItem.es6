import React, { Component } from 'react'

import { LessonText } from '../components/LessonText.es6'
import { CheckText } from '../components/CheckText.es6'
import { PracticeText } from '../components/PracticeText.es6'
import { StatusBtns } from '../components/StatusBtns.es6'

export class HistoryItem extends Component {

  constructor(props) {
    super(props)
  }

  changeYoutubeURL(youtube_url) {
    this.props.setYoutubeURL(youtube_url)
  }

  render(){
    const { item, entrance_exam_flag } = this.props
    return (
      <div className="curriculum-contents">
        {item.sub_units.map((sub_unit, i) =>
          <div className="curriculum-container" key={i} >
            <div className="curriculum-info">
              <p className="title">{sub_unit.sub_unit_name}
                {(() => {
                  if (entrance_exam_flag === false) {
                    return <span>（{Math.floor(sub_unit.total_duration / 60)}分）</span>
                  }
                })()}
              </p>
              <div className="caption">{sub_unit.sub_unit_goals.map((goal, j) => 
                <p key={j}>{goal}</p>
                )}</div>
                {sub_unit.videos.map((video, videoIndex) => 
                  <div className="btns" key={videoIndex}>
                    <LessonText video={video} />
                    <CheckText video={video} />
                    <PracticeText video={video} />
                    {(() => {
                      if (video.youtube_url !== null && video.youtube_url !== undefined) {
                        return <div className="btns-area">
                            <h5 className="title movie">映像授業{videoIndex + 1}</h5>
                            <input type="button" className="el-button size-mini" value="再生" 
                            onClick={this.changeYoutubeURL.bind(this, video.youtube_url)} />
                          </div>
                      }
                    })()}
                  </div>
                )}
            </div>
            <div className="curriculum-settings">
              <StatusBtns editFlag={false} learning_status={sub_unit.learning_status} />
            </div>
          </div>
          )}
      </div>
    )
  }
}
