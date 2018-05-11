import React, { Component } from 'react'
import { Subjects } from './Subjects.es6'

export class Agreements extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { agreements, row } = this.props
    return (
      <div className="weekSection">
        {agreements.map((agreement, j) =>
          <Subjects subjects={agreement.subjects || []} row={row} column={j} key={j} />
        )}
      </div>
    )
  }
}