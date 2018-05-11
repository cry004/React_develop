import React, { Component } from 'react'
import classNames from 'classnames'

export class Tab extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { text, clickFunc, isActive } = this.props
    const linkClass = isActive === true ? 'is-active' : ''
    return (
      <li className="bl-tab-list">
        <a onClick={clickFunc} className={linkClass}>
          {text}
        </a>
      </li>
    )
  }
}