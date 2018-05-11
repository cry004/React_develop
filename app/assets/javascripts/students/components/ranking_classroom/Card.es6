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
    const iconClass = `el-icon-classroom u-left is-${parseInt(ranking.classroom.color || 0, 10)}`
    const rankingChange = ranking['ranking_changes'][currentTab.regionType]
    const arrowClass = classNames("arrow", {
      'is-down': rankingChange < 0,
      'is-up': rankingChange > 0
    })
    const arrowText = separateByThreeDigits(rankingChange < 0 ? -rankingChange : rankingChange)
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
          <p className="card-profile-name">{ranking.classroom.name}</p>
          <p className="card-profile-detail">
            {ranking.classroom.prefecture_name}
            <br/>
          </p>
          <div className="card-profile-number">
            <p className="card-time"><span>{separateByThreeDigits(ranking.learning_time.hours)}</span>時間<span>{ranking.learning_time.minutes}</span>分</p>
          </div>
        </div>
      </div>
    )
  }
}