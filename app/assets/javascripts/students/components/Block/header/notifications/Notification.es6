import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import classNames from 'classnames'

import{ currentNewsId } from '../../../../actions/news.es6'
import{ updateCurrentTeacherId } from '../../../../actions/teacher.es6'
import { requestUser } from '../../../../actions/user.es6'

export class Notification extends Component {
  constructor(props) {
    super(props)
  }
  clickNotification(e, notificationType, id) {
    const { accessToken, dispatch } = this.props
    if (notificationType === "teacher_recommendation") {
      dispatch(updateCurrentTeacherId(id))
      window.location.hash = `/teacher`
    } else if(notificationType === "news") {
      dispatch(currentNewsId(id))
      window.location.hash = "/news"
    }
  }
  render() {
    const { notification } = this.props
    const imageClass = classNames('el-menu-notification-image u-left', { 'is-teacher': notification.notification_type === 'teacher_recommendation' })
    const listClass = classNames('el-menu-notification u-clearfix', { 'is-unread': notification.unread === true })
    return (
      <li className={listClass} onClick={(e) => this.clickNotification(e, notification.notification_type ,notification.notification_id)}>
        <div className={imageClass}></div>
        <div className="el-menu-notification-text u-left">
          <p className="el-menu-notification-text-content">
            {notification.title}
          </p>
          <time className="el-menu-notification-text-date">{notification.date}</time>
        </div>
      </li>
    )
  }
}
