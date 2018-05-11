import React, { Component } from 'react'

export class CompleteRequestPoint extends Component {
    constructor(props) {
    super(props)
  }
  render() {
    const { hidePopup } = this.props
    return (
      <div className="complete-request-point">
        <p>
          リクエストしました。
        </p>
        <a className="el-button size-small is-blue" onClick={hidePopup}>OK</a>
      </div>
    )
  }
}