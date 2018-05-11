import React, { Component } from 'react';
import PropTypes from 'prop-types'

export class Day extends Component {
  render() {
    let classes = ['Day'];
    if (this.props.today.isSame(this.props.date, 'day')) {
      classes.push('today');
    }
    if (this.props.selected && this.props.selected.isSame(this.props.date, 'day')) {
      classes.push('selected');
    }
    classes = classes.concat(this.props.classes);

    let body
    if (!!this.props.children) {
      body = this.props.children;
    }
    else {
      body = (
        <button className="Day-inner"
          onClick={() => this.props.handleClick(this.props.date)}>
          {this.props.date.format('D')}
        </button>
      )
    }

    return (
      <td className={classes.join(' ')}
        data-date={this.props.date.toISOString()}
        data-day={this.props.date.format('D')}
      >
        {body}
      </td>
    );
  }
};

Day.propTypes = {
  handleClick: PropTypes.func.isRequired,
  date: PropTypes.object.isRequired,
  //month: PropTypes.object.isRequired,
  today: PropTypes.object.isRequired,
  selected: PropTypes.object,
  children: PropTypes.node
}
