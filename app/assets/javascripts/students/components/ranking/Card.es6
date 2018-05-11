
import React, { Component } from 'react'
import classNames from 'classnames'
import { separateByThreeDigits } from '../../util/string.es6'

export class Card extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { ranking, rank, currentTab } = this.props
    const cardClass = `card u-clearfix is-${rank}`
    const iconClass = `el-icon u-left is-${parseInt(ranking.student.avatar || 0, 10)}`
    const arrowClass = classNames("arrow", {
      'is-down': ranking['ranking_changes'][currentTab] < 0,
      'is-up': ranking['ranking_changes'][currentTab] > 0
    })
    const arrowText = separateByThreeDigits(ranking['ranking_changes'][currentTab] < 0 ? -ranking['ranking_changes'][currentTab] : ranking['ranking_changes'][currentTab])
    return(
      <div className={cardClass}>
        <p className={arrowClass}>
          {arrowText}
        </p>
        <div className="card-rank u-left">
          {(() => {
            if(rank < 4) {
              return (
                <span>位</span>
              )
            } else {
              return (
                <div className="card-rank-text">
                  {rank}<span>位</span>
                </div>
              )
            }
          })()}
        </div>
        <div className={iconClass}>
        </div>
        <div className="card-profile u-left">
          <p className="card-profile-name">{ranking.student.nick_name}さん</p>
          <p className="card-profile-detail">
            {ranking.student.school_year}　{ranking.student.school_address}
            <br/>
            <span className="card-profile-detail-school"> {ranking.student.classroom_name || "Try IT 会員"} </span>
          </p>
          <div className="card-profile-number">
            <p className="card-profile-number-level"><span>Lv </span>{ranking.student.level}</p>
            <p className="card-profile-number-trophy">{ranking.student.trophies_count}</p>
            <p className="card-time"><span>{separateByThreeDigits(ranking.learning_time.hours)}</span>時間<span>{ranking.learning_time.minutes}</span>分</p>
          </div>
        </div>
      </div>
    )
  }
}