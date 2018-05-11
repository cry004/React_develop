import React, { Component } from 'react'

import { Graph } from '../../Element/graph/Graph.es6'

import { updateCurrentCource,
  requestVideos } from '../../../actions/videos.es6'

export class SubjectCard extends Component {
  constructor(props) {
    super(props)
  }
  selectVideoList(year, subject) {
    const { accessToken, dispatch } = this.props;
    dispatch(requestVideos(accessToken.accessToken, year, subject))
    dispatch(updateCurrentCource(year, subject))
    window.location.hash = '/videos'
  }
  render() {
    const { subject, currentTab } = this.props
    const titleClass = `card-cource u-color-${currentTab}`
    return(
      <div className="card u-clearfix" onClick={()=>this.selectVideoList(subject.schoolyear, subject.subject_key)}>
        <div className="u-left">
          <p className="card-subject">
            {subject.title.school_name}{subject.title.subject_name}&nbsp;&nbsp;{subject.title.subject_type}
          </p>
          <p className={titleClass}>
            {subject.title.subject_detail_name}
          </p>
          <p className="card-trophy">
            <span>{subject.trophies_progress.completed_trophies_count}</span> / {subject.trophies_progress.total_trophies_count}
          </p>
          <p className="card-link">クリックして授業へ</p>
        </div>
        <div className="l-right">
          <Graph completedVideosCount={subject.videos_progress.completed_videos_count} totalVideosCount={subject.videos_progress.total_videos_count}
            subject={currentTab} />
        </div>
      </div>
    )
  }
}
