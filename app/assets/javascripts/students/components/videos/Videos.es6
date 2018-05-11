import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'
import { createMarkup } from '../../util/createMarkup.es6'

import { Subject } from '../Block/subject/Subject.es6'
import { Video } from '../Element/video/Video.es6'
import { Graph } from '../Element/graph/Graph.es6'
import { Unit } from './Unit.es6'

import { updateVideoId } from '../../actions/video.es6'
import { requestVideos,
  updateFilteredUnits,
  updateVideosCurrentUnit } from '../../actions/videos.es6'
import { isShowLoading } from '../../actions/loading.es6'




// FORDEBUG
import { postPlayTime } from '../../actions/video.es6'



class Videos extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, videos, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(updateVideosCurrentUnit(null))
    dispatch(requestVideos(accessToken.accessToken, videos.year, videos.subject))
  }
  componentWillReceiveProps(nextProps) {
    const { videos, dispatch } = this.props
    if (videos.isFetching === true && nextProps.videos.isFetching === false) {
      dispatch(isShowLoading(false))
    } else if (videos.isFetching === false && nextProps.videos.isFetching === true) {
      dispatch(isShowLoading(true))
    }
    if (videos.subject !== nextProps.videos.subject
      || videos.year !== nextProps.videos.year) {
      dispatch(updateVideosCurrentUnit(null))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  filterUnits(i) {
    const { videos, dispatch } = this.props
    let nextFilterVideos = []
    nextFilterVideos[0] = videos.units[i]
    dispatch(updateVideosCurrentUnit(i))
    dispatch(updateFilteredUnits(nextFilterVideos))
  }
  showAll() {
    const { videos, dispatch } = this.props
    dispatch(updateVideosCurrentUnit(null))
    dispatch(updateFilteredUnits(videos.units))
  }
  selectVideo(videoId) {
    const { dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }

  // FORDEBUG
  // allWatched(videos) {
  //   const { accessToken, dispatch } = this.props
  //   videos.forEach((video, index) => {
  //     dispatch(postPlayTime(accessToken.accessToken, video.video_id, parseInt(video.duration.seconds , 10)))
  //   })
  // }
  // otherThanLastWatched(videos) {
  //   const { accessToken, dispatch } = this.props
  //   videos.pop()
  //   videos.forEach((video, index) => {
  //     dispatch(postPlayTime(accessToken.accessToken, video.video_id, parseInt(video.duration.seconds , 10)))
  //   })
  // }
  // watchThisVideo(videoId, duration) {
  //   const { accessToken, dispatch } = this.props
  //   dispatch(postPlayTime(accessToken.accessToken, videoId, parseInt(duration.seconds , 10)))
  // }


  render() {
    const { videos, accessToken, dispatch } = this.props
    const subjectClass = `bl-subject-info-cource u-color-${videos.title.subjectKey}`
    return (
      <div className="page-videolist">
        {/*FIX ME: learning_progressesと共通化 */}
        <div className="bl-subject">
          <div className="bl-subject-info">
            <p className="bl-subject-info-subject">{videos.title.schoolName}{videos.title.subjectName} {videos.title.subjectType}</p>
            <p className={subjectClass}>{videos.title.subjectDetailName}</p>
              <p className="bl-subject-info-trophy">
              <span>{videos.completedTrophiesCount}</span> / {videos.totalTrophiesCount}
            </p>
          </div>
          <div className="bl-subject-graph">
            <Graph completedVideosCount={videos.completedVideosCount} totalVideosCount={videos.totalVideosCount} subject={videos.title.subjectKey} />
          </div>
          {(() => {
            if(videos.videosSuggest) {
              return (
                <div className="bl-subject-videos">
                  {videos.videosSuggest.videos.map((video, j) =>
                    <div className="bl-subject-videos-video" onClick={() => this.selectVideo(video.video_id)} key={j} >
                      <Video video={video} />
                    </div>
                  )}
                </div>
              )
            }
          })()}
        </div>

        <div className="container u-clearfix">
          <div className="menu u-left">
            <a className={classNames('menu-head', {'is-active': videos.currentUnitIndex  === null})} onClick={()=>this.showAll()}>
              すべて表示
            </a>
            {videos.units.map((unit, i) =>
              <a key={i} className={classNames('menu-list', {'is-active': i === videos.currentUnitIndex, 'is-done': unit.completed === true})} onClick={()=>this.filterUnits(i)} dangerouslySetInnerHTML={createMarkup(unit.title)} />
            )}
          </div>
          <div className="videos u-left">
            <div className="u-clearfix">
              <p className="videos-setting">教科書設定：{videos.schoolbookName}</p>
            </div>
            {videos.filteredUnits.map((unit, i) =>
              <div key={i}>
                {/*<p>(※クリック数×動画本数分APIが叩かれるのでダブルクリックしないように注意してください)</p>
                <button onClick={()=>this.allWatched(unit.videos)}>ユニット全てを1度ずつ視聴する</button>　<button onClick={()=>this.otherThanLastWatched(unit.videos)}>ユニット最後１つ以外を１度ずつ視聴する</button>*/}
                {/*<Unit unit={unit} selectVideo={this.selectVideo.bind(this)} watchThisVideo={this.watchThisVideo.bind(this)} />*/}
                <Unit unit={unit} selectVideo={this.selectVideo.bind(this)} />
              </div>
            )}
            {/*<a className="el-button is-white">もっと見る</a>*/}
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    videos: state.videos
  }
}

export default connect(mapStateToProps)(Videos);
