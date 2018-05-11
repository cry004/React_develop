import React, { Component } from 'react';

export class DayOfWeek extends Component {
  render() {
    return <th className="DayOfWeek">{this.props.date.locale("ja").format('ddd')}</th>
  }
}
