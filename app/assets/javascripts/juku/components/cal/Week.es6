import React, { Component } from 'react';
import classNames from 'classnames'

export class Week extends Component {
  render() {
    let isWeek = false
    if(this.props.schedule_type == 'week') {
      isWeek = true
    }
    let classes = classNames('Week', {select: isWeek});
    return <tr className={classes}>{this.props.children}</tr>
  }
}


