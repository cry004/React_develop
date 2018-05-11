import React, { Component } from 'react'
import classNames from 'classnames'

export class Loading extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { isFetched } = this.props
    const LoadingClass = classNames('Loading', {'is-hidden': isFetched})
    return(
      <div className={LoadingClass}></div>
    )
  }

}