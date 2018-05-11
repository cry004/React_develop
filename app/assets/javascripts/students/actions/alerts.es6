export const UPDATE_ALERTS = 'UPDATE_ALERTS'

export function updateAlerts(alerts = []) {
  return {
    type: UPDATE_ALERTS,
    alerts: alerts
  }
}