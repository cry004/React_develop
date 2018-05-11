import React, { Component } from 'react'
import classNames from 'classnames'

import { separateByThreeDigits } from '../../util/string.es6'

export class Status extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { classroom, learningTime, currentClassroomRankings, rankingChanges, classroomType, rankingMonth, currentTerm } = this.props
    const iconClass = `el-icon-classroom u-left is-${parseInt(classroom.color, 10)}`
    const arrowPrefectureClass = classNames("arrow", {
      'is-down': rankingChanges.prefecture < 0,
      'is-up': rankingChanges.prefecture > 0
    })
    const arrowPrefectureText = rankingChanges.prefecture < 0 ? separateByThreeDigits(-rankingChanges.prefecture) : separateByThreeDigits(rankingChanges.prefecture)
    const arrowNationalClass = classNames("arrow", {
      'is-down': rankingChanges.national < 0,
      'is-up': rankingChanges.national > 0
    })
    const arrowNationalText = rankingChanges.national < 0 ? separateByThreeDigits(-rankingChanges.national) : separateByThreeDigits(rankingChanges.national)
    const prefectureRank = currentClassroomRankings.prefecture ? separateByThreeDigits(currentClassroomRankings.prefecture) : '-'
    const nationalRank = currentClassroomRankings.national ? separateByThreeDigits(currentClassroomRankings.national) : '-'
    const watchText = currentTerm === 'last_7_days' ? "今週の視聴時間" : `${rankingMonth}月の視聴時間`
    return(
      <div className="status u-clearfix">
        <div className="status-inner">
          <div className={iconClass}>
          </div>
          <div className="profile u-left">
            <p className="profile-name">{classroom.name}</p>
            <p className="profile-detail">
              {classroom.prefecture_name}
              <br/>
            </p>
            <div className="profile-number">
              <p className="profile-number-time">{watchText}<span>{separateByThreeDigits(learningTime.hours)}</span>時間<span>{learningTime.minutes}</span>分</p>
            </div>
          </div>
          {classroomType === 'classroom' &&
            <div className="status-ranking u-right">
              <div className="status-ranking-row"> 
                <p className="status-ranking-row-item">
                  教室ランキング - {classroom.prefecture_name}
                </p>
                <p className="status-ranking-row-rank">
                  <span>{prefectureRank}</span>位
                </p>
                <p className={arrowPrefectureClass}>
                  {arrowPrefectureText}
                </p>
              </div>
              <div className="status-ranking-row"> 
                <p className="status-ranking-row-item">
                  教室ランキング - 全国
                </p>
                <p className="status-ranking-row-rank">
                  <span>{nationalRank}</span>位
                </p>
                <p className={arrowNationalClass}>
                  {arrowNationalText}
                </p>
              </div>
            </div>
          }
          {classroomType === 'schoolhouse' &&
            <div className="status-ranking u-right">
              <div className="status-ranking-row"> 
                <p className="status-ranking-row-item">
                  校舎ランキング - 全国
                </p>
                <p className="status-ranking-row-rank">
                  <span>{nationalRank}</span>位
                </p>
                <p className={arrowNationalClass}>
                  {arrowNationalText}
                </p>
              </div>
            </div>
          }
        </div>
      </div>
    )
  }
}