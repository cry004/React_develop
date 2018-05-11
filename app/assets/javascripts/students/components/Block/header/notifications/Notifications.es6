import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import classNames from 'classnames'

import { Notification } from './Notification.es6'

import { requestNotifications } from '../../../../actions/notifications.es6'
import { currentNewsId } from '../../../../actions/news.es6'
import { requestUser } from '../../../../actions/user.es6'


export class Notifications extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestNotifications(accessToken.accessToken))
    dispatch(requestUser(accessToken.accessToken))
  }
  updateCurrentNotification(index) {
    const { dispatch } = this.props
  }
  seeMore() {
    const { dispatch } = this.props
    dispatch(currentNewsId(null))
    window.location.hash = "/news"
  }
  render() {
    const { notifications, accessToken, dispatch, user } = this.props
    const messageClass = classNames('bl-header-menu-notification-bell',{ 'is-unread': user.unreadNotificationsCount > 0})
    return (
      <div className="bl-header-menu-notification" >
        <a className={ messageClass }>
          { user.unreadNotificationsCount > 0 &&
            <div className="unread-message">{user.unreadNotificationsCount}</div>
          }
        </a>
        <div className="el-menu is-notification">
          <div className="el-menu-header">お知らせ</div>
          <div className="el-menu-main">
            {notifications.notifications.map((notification, i) => {
              return (
                <Notification notification={notification} key={i} accessToken={accessToken} dispatch={dispatch} />
              )
            })}
          </div>
          <div className="el-menu-footer"><a onClick={()=>this.seeMore()}>もっと見る</a></div>
        </div>
      </div>
    )
  }
}
