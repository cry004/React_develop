import React, { Component } from 'react'
import classNames from 'classnames'

import { isShowLoading } from '../../../actions/loading.es6'

export class Loading extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { loading } = this.props
    const loadingClass = classNames('bl-loading', {
      'u-hidden': loading.isShowLoading === false
    })
    return (
      <div className={loadingClass}>
      </div>
    )
  }
}