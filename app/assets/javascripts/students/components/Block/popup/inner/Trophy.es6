import React, { Component } from 'react'
import classNames from 'classnames'

import { showPopup } from '../../../../actions/popup.es6'

export class Trophy extends Component {
  constructor(props) {
    super(props)
  }
  onClickOk() {
    const { args, hidePopup, dispatch } = this.props
    if (args.levelUpFlag === true) {
      dispatch(showPopup('level', {
        level: args.level
      }))
    } else {
      hidePopup()
    }
  }
  render() {
    const { hidePopup, args } = this.props
    const subjectClass = `u-color-${args.subjectKey || 'english'}`
    const tropyClass = classNames('trophy', {
      'is-course': args.isCourseComplete
    })
    const experienceNum = args.isCourseComplete === true ? '3,000' : '1,000'
    return (
      <div className={tropyClass}>
        <p className="trophy-heading">トロフィーゲット！</p>
        <div className="trophy-image"></div>
        <p className="trophy-text">
          <span className={subjectClass}>{args.schoolName}{args.subjectName} {args.subjectType} {args.subjectDetailName}<br/></span>
          <span className="trophy-text-title">{args.unitName}<br/></span>
          を修了しました！
        </p>
        {args.trophiesProgress &&
          <p className="trophy-number">
            <span>{args.trophiesProgress.completed_trophies_count}</span> / {args.trophiesProgress.total_trophies_count}
          </p>
        }
        <p className="trophy-experience">
          <span>経験値</span> + {experienceNum}
        </p>
        <a className="el-button is-blue size-small" onClick={() => this.onClickOk()}>OK</a>
      </div>
    )
  }
}