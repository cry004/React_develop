import React, { Component } from 'react'

export class ReportComment extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { learning_status, sub_unit_goals} = this.props
    let comment
    switch(learning_status){
      case 'pass':
        comment = `${sub_unit_goals}について、よく理解できています。`
        break;
      case 'failure':
        comment = `${sub_unit_goals}について、もう一度復習が必要です。`
        break;
      default:
        comment = ``
        break;
    }
    return (
      <p>{comment}</p>
    )
  }
}
