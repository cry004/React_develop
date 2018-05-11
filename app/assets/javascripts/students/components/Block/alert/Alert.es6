import React, { Component } from 'react'
import classNames from 'classnames'

import { updateAlerts } from '../../../actions/alerts.es6'

export class Alert extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { dispatch } = this.props
    dispatch(updateAlerts([]))
  }
  hideError() {
    const { dispatch } = this.props
    dispatch(updateAlerts([]))
  }
  render() {
    const { alerts } = this.props
    const alertClass = classNames('bl-alert', {
      'u-hidden': alerts.alerts.length < 1
    })
    return (
      <div className={alertClass} style={{left: scroll.left}}>
        {(() => {
          if(alerts.alerts.length > 0) {
            return (
              <p>{alerts.alerts[0]}</p>
            )
          }
        })()}
        <div className="bl-alert-closer" onClick={()=>this.hideError()} ></div>
      </div>
    )
  }
}