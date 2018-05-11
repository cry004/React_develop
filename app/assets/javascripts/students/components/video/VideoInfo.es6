import React, { Component } from 'react' 
import classNames from 'classnames'
import { createMarkup } from '../../util/createMarkup.es6'
import { separateByThreeDigits } from '../../util/string.es6'

export class VideoInfo extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { video, toggleBookmark, updateVideoQuestionFlag } = this.props
    const bookmarkText = video.isBookmarked === true ? 'ブックマーク済み' : 'ブックマークする'
    const bookmarkClass = classNames('videoinfo-buttons-button is-bookmark u-left', {'is-booked': (video.isBookmarked === true)})
    const subjectClass = `videoinfo-info-subject u-color-${video.subject.key}`
    return(
      <div className="videoinfo">
        <div className="videoinfo-info">
          {video.currentStudentWatchedCount > 0 &&
            <p className="el-watched"> {separateByThreeDigits(video.currentStudentWatchedCount)} 回視聴済み </p>
          }
          <p className={subjectClass}>
            {video.title.school_name}{video.title.subject_name} {video.title.subject_type} {video.title.subject_detail_name}
          </p>
          <p className="videoinfo-info-title" dangerouslySetInnerHTML={createMarkup(video.name)} />
          <p className="videoinfo-info-subtitle" dangerouslySetInnerHTML={createMarkup(video.subname)} /> 
        </div>
        <div className="videoinfo-buttons u-clearfix">
          {video.lockedVideo === false &&
            <a className={bookmarkClass} onClick={toggleBookmark}>
              {bookmarkText}
            </a>
          }
          <a className="videoinfo-buttons-button is-question u-left" onClick={updateVideoQuestionFlag.bind(this)}>
            質問する
          </a>
          {/* 今回のリリースではなし
          <a className="videoinfo-buttons-button is-share u-left">
            シェアする
          </a>
          */}
          <p className="videoinfo-buttons-watched u-right">
            視聴回数 {separateByThreeDigits(video.totalWatchedCount)} 回
          </p>
        </div>
      </div>
    )
  }
}