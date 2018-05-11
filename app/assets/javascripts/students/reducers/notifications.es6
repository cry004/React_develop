import _ from 'lodash'
import { RECEIVE_NOTIFICATIONS,
  RECEIVE_READ_NOTIFICATION } from '../actions/notifications.es6'

const initialState = {
  notifications: []
}

function notifications(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_NOTIFICATIONS:
      return Object.assign({}, state, {
        notifications: action.notifications
      })
    case RECEIVE_READ_NOTIFICATION:
      let notifications = _.map(state.notifications, (notification, index)  => {
        if (notification.notification_id === action.id && notification.notification_type === action.notificationType) {
          let notice = notification
          notice.unread = false
          return notice
        } else {
          return notification
        }
      })
      return Object.assign({}, state, {
        notifications: notifications
      })
    default:
      return state
  }
}

export default notifications