import React, { Component } from 'react'

import { Video } from '../../Element/video/Video.es6'
import { Graph } from '../../Element/graph/Graph.es6'
import { updateVideoId } from '../../../actions/video.es6'
import { updateCurrentCource,
  requestVideos } from '../../../actions/videos.es6'
import { showPopup } from '../../../actions/popup.es6'

export class Subject extends Component {
  constructor(props) {
    super(props)
  }
  selectVideoList(year, subject) {
    const { accessToken, dispatch } = this.props;
    dispatch(requestVideos(accessToken.accessToken, year, subject))
    dispatch(updateCurrentCource(year, subject))
    window.location.hash = '/videos'
  }
  selectVideo(videoId) {
    const { accessToken, dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  render() {
    const { subject } = this.props
    const titleClass = `bl-subject-info-cource u-color-${subject.subject_key}`

    return(
      <div className="bl-subject">
        <div className="bl-subject-info">
          <p className="bl-subject-info-subject">{subject.school_name}{subject.subject_name} {subject.subject_type}</p>
          <p className={titleClass}>{subject.subject_detail_name}</p>
          <p className="bl-subject-info-trophy">
            <span>{subject.completed_trophies_count}</span> / {subject.total_trophies_count}
          </p>
          <a className="bl-subject-info-link" onClick={() => this.selectVideoList(subject.schoolyear, subject.subject_name_and_type)}>クリックして授業へ</a>
        </div>
        <div className="bl-subject-graph">
          <Graph completedVideosCount={subject.learned_video_count} totalVideosCount={subject.total_video_count} subject={subject.subject_key} />
        </div>
        {(() => {
          if(subject.videos_suggest) {
            return (
              <div className="bl-subject-videos">
                {subject.videos_suggest.videos.map((video, j) =>
                  <div className="bl-subject-videos-video" onClick={() => this.selectVideo(video.video_id)} key={j} >
                    <Video video={video} isSubject="false" />
                  </div>
                )}
              </div>
            )
          }
        })()}
      </div>
    )
  }
}
