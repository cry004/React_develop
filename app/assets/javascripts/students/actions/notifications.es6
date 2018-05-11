export const REQUEST_NOTIFICATIONS = 'REQUEST_NOTIFICATIONS'
export const RECEIVE_NOTIFICATIONS = 'RECEIVE_NOTIFICATIONS'
export const RECEIVE_READ_NOTIFICATION = 'RECEIVE_READ_NOTIFICATION'

export function requestNotifications(accessToken = "") {
  return {
    type: REQUEST_NOTIFICATIONS,
    accessToken: accessToken
  }
}

export function receiveNotifications(notifications) {
  return {
    type: RECEIVE_NOTIFICATIONS,
    notifications: notifications
  }
}

export function receiveReadNotification(id, notificationType) {
  return {
    type: RECEIVE_READ_NOTIFICATION,
    id: id,
    notificationType: notificationType
  }
}