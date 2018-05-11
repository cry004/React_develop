import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import classNames from 'classnames'
import { separateByThreeDigits } from '../../../util/string.es6'

export class MyStatus extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { learningProgresses, nickName, changeText, pathname } = this.props
    const graphWidth = 280 * learningProgresses.levelProgress / 100
    const iconClass = `el-icon is-${learningProgresses.student.avatar}`
    const today = new Date()
    const hour = today.getHours()
    const mystatusClass = classNames('bl-mystatus', {
      'is-afternoon': hour > 15 && hour < 19,
      'is-evening': hour < 6 || hour > 18
    })

    return(
      <div className={mystatusClass}>
        {(() => {
          if (pathname === "/settings_profile") {
            return (
              <div className={iconClass}>
                <Link to="/avatar" className="bl-mystatus-icon-select" >
                  アイコン
                  <br/>
                  を選択
                </Link>
              </div>
            )
          } else {
            return (
              <div className={iconClass}></div>
            )
          }
        })()}
        <div className="bl-mystatus-profile">
          {(() => {
            if (pathname === "/settings_profile") {
              return (
                <input className="bl-mystatus-profile-input" type="text" value={nickName} onChange={changeText}  />
              )
            } else {
              return (
                <p className="bl-mystatus-profile-name">
                  <span>{learningProgresses.student.nickName}</span>さん
                </p>
              )
            }
          })()}
          
          <p className="bl-mystatus-profile-detail">
            {learningProgresses.student.schoolYear}　{learningProgresses.student.schoolAddress}
            <br/>
            <span className="bl-mystatus-profile-detail-school">{learningProgresses.student.classroomName}</span>
          </p>
        </div>
        <div className="bl-mystatus-status"> 
          <p className="bl-mystatus-status-trophy">
            {learningProgresses.completedTrophiesCount}
          </p>
          <p className="bl-mystatus-status-done">
            {learningProgresses.watchedVideosCount}
          </p>
          <p className="bl-mystatus-status-time">
            総学習時間
            <span>{separateByThreeDigits(learningProgresses.learningTime.hours)}</span>
            時間
            <span>{learningProgresses.learningTime.minutes}</span>
            分
          </p>
        </div>
        <div className="bl-mystatus-level">
          <p className="bl-mystatus-level-rank">Lv<span>{learningProgresses.student.level}</span></p>
          <div className="bl-mystatus-level-graph">
            <div className="bl-mystatus-level-graph-inner" style={{width: graphWidth}}></div>
          </div>
          <p className="bl-mystatus-level-next">次のレベルまであと　{learningProgresses.experiencePointForNextLevel}</p>
        </div>
      </div>
    )
  }
}
