import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { addErrorMessage, initErrorMessage } from '../actions/ErrorMessage.es6'

export class ErrorMessage extends Component {

  constructor(props) {
    super(props)
  }

  componentWillReceiveProps(nextProps) {
    const { errors } = nextProps
    const { dispatch } = this.props
    if (errors.length > 0) {
      setTimeout(function() {
        dispatch(initErrorMessage())
      }, 8000)
    }
  }

  render() {
    const { errors } = this.props
    let errorMessageClass = classNames('ErrorMessage', { 'is-hidden': (errors.length < 1)})
    return(
      <div className={errorMessageClass}>
        {errors.map((error, index) =>
          <p key={index}>{error.status} {error.message}</p>
        )}
      </div>
    )
  }

}

const mapStateToProps = (state) => {
  return {
    errors: state.requestErrorMessage.errors
  }
}

export default connect(mapStateToProps)(ErrorMessage);