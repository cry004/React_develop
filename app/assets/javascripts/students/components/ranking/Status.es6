import React, { Component } from 'react'
import classNames from 'classnames'

import { separateByThreeDigits } from '../../util/string.es6'

export class Status extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { student, learningTime, currentStudentRankings, rankingChanges, rankingMonth, currentTerm } = this.props
    const iconClass = `el-icon u-left is-${parseInt(student.avatar, 10)}`
    const arrowPrefectureClass = classNames("arrow", {
      'is-down': rankingChanges.prefecture < 0,
      'is-up': rankingChanges.prefecture > 0
    })
    const arrowPrefectureText = rankingChanges.prefecture < 0 ? separateByThreeDigits(-rankingChanges.prefecture) : separateByThreeDigits(rankingChanges.prefecture)
    const arrowNationalClass = classNames("arrow", {
      'is-down': rankingChanges.national < 0,
      'is-up': rankingChanges.national > 0
    })
    const arrowClassroomClass = classNames("arrow", {
      'is-down': rankingChanges.classroom < 0,
      'is-up': rankingChanges.classroom > 0
    })
    const arrowNationalText = rankingChanges.national < 0 ? separateByThreeDigits(-rankingChanges.national) : separateByThreeDigits(rankingChanges.national)
    const prefectureRank = currentStudentRankings.prefecture ? separateByThreeDigits(currentStudentRankings.prefecture) : '-'
    const nationalRank = currentStudentRankings.national ? separateByThreeDigits(currentStudentRankings.national) : '-'
    const classroomRank = currentStudentRankings.classroom ? separateByThreeDigits(currentStudentRankings.classroom) : '-'
    const arrowClassroomText = rankingChanges.classroom < 0 ? separateByThreeDigits(-rankingChanges.classroom) : separateByThreeDigits(rankingChanges.classroom)
    const watchText = currentTerm === 'last_7_days' ? "今週の視聴時間" : `${rankingMonth}月の視聴時間`
    const calssroomText = student.classroom_type === 'classroom' ? "教室" : "校舎"
    return(
      <div className="status u-clearfix">
        <div className="status-inner">
          <div className={iconClass}>
          </div>
          <div className="profile u-left">
            <p className="profile-name">{student.nick_name}さん</p>
            <p className="profile-detail">
              {student.school_year}　{student.school_address}
              <br/>
              <span className="profile-detail-school">{student.classroom_name || 'Try IT 会員'}</span>
            </p>
            <div className="profile-number">
              <p className="profile-number-level"><span>Lv </span>{student.level}</p>
              <p className="profile-number-trophy">{student.trophies_count}</p>
              <p className="profile-number-time">{watchText}<span>{separateByThreeDigits(learningTime.hours)}</span>時間<span>{learningTime.minutes}</span>分</p>
            </div>
          </div>
          <div className="status-ranking u-right">
            {student.classroom_type &&
              <div className="status-ranking-row"> 
                <p className="status-ranking-row-item">
                  個人ランキング - {calssroomText}
                </p>
                <p className="status-ranking-row-rank">
                  <span>{classroomRank}</span>位
                </p>
                <p className={arrowClassroomClass}>
                  {arrowClassroomText}
                </p>
              </div>
            }
            {student.school_address &&
              <div className="status-ranking-row"> 
                <p className="status-ranking-row-item">
                  個人ランキング - {student.school_address}
                </p>
                <p className="status-ranking-row-rank">
                  <span>{prefectureRank}</span>位
                </p>
                <p className={arrowPrefectureClass}>
                  {arrowPrefectureText}
                </p>
              </div>
            }
            <div className="status-ranking-row"> 
              <p className="status-ranking-row-item">
                個人ランキング - 全国
              </p>
              <p className="status-ranking-row-rank">
                <span>{nationalRank}</span>位
              </p>
              <p className={arrowNationalClass}>
                {arrowNationalText}
              </p>
            </div>
          </div>
        </div>
      </div>
    )
  }
}