import React, { Component } from 'react'
import { Agreements } from './Agreements.es6'

export class Periods extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { periods } = this.props
    return (
      <div className="content is-periods">
        {periods.map((period, j) =>
          <Agreements agreements={period.agreements} row={j} key={j} />
        )}
      </div>
    )
  }
}