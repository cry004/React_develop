import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import moment from 'moment'
import classNames from 'classnames'

import { Day } from './Day.es6'
import { DayOfWeek } from './DayOfWeek.es6'
import { Week } from './Week.es6'

export class Calendar extends Component {

    constructor(props) {
      super(props)
    }

    componentWillMount() {
      let date = moment(new Date(this.props.start_date));
      let month = moment(new Date(this.props.start_date));
      this.state = {
        date: date,
        month: month
      }

      moment.locale(this.props.locale);

      if (!!this.state.date) {
        this.state.date.locale(this.props.locale)
      }

      this.state.month.locale(this.props.locale)
    }

    componentWillUpdate(nextProps, nextState) {
        moment.locale(this.props.locale);

        if (!!nextState.date) {
          nextState.date.locale(this.props.locale)
        }

        nextState.month.locale(this.props.locale)
    }

    handleClick(date) {
      let flag = this.props.onSelect(date, this.state.date, this.state.month);

      if (flag === true) {
        this.setState({
          date: moment(new Date(date))
        });
      }
      else if (flag === false) {
        this.setState({
          date: null
        })
      }

      if(this.props.schedule_type == 'day') {
        let formattedDate = date.format("YYYY-MM-DD")
        this.props.onCalChange(formattedDate, formattedDate)
      } else if(this.props.schedule_type == 'week') {
        let mon = moment(new Date(date)).isoWeekday(1).format("YYYY-MM-DD")
        let sun = moment(new Date(date)).isoWeekday(7).format("YYYY-MM-DD")
        this.props.onCalChange(mon, sun)
      }
      
    }

    previous() {
      this.setState({
        month: moment(new Date(this.state.month)).subtract(1, 'month')
      });
    }

    next() {
      this.setState({
        month: moment(new Date(this.state.month)).add(1, 'month')
      });
    }

    render() {
        const { startOfWeekIndex, dayRenderer, isActive, page_type } = this.props;

        let classes = classNames('Calendar', {active: isActive, [`${page_type}`]: true});
        let today = moment();

        let date = this.state.date;
        let month = this.state.month;

        let current = month.clone().startOf('month').day(startOfWeekIndex);
        if (current.date() > 1 && current.date() < 7) {
          current.subtract(7, 'd');
        }

        let end = month.clone().endOf('month').day(7 + startOfWeekIndex);
        if (end.date() > 7) {
          end.subtract(7, 'd');
        }

        let elements = [];
        let days = [];
        let week = 1;
        let i = 1;
        let daysOfWeek = [];
        let day = current.clone();
        for (let j = 0; j < 7; j++) {
          let dayOfWeekKey = 'dayOfWeek' + j;
          daysOfWeek.push(<DayOfWeek key={dayOfWeekKey} date={day.clone()} />);
          day.add(1, 'days');
        }
        while (current.isBefore(end)) {
          let dayClasses = this.props.dayClasses(current);
          if (!current.isSame(month, 'month')) {
            dayClasses = dayClasses.concat(['other-month']);
          }
          let isCurrentMonth = current.isSame(month, 'month');
          let props = {
            date: current.clone(),
            selected: date,
            month: month,
            today: today,
            classes: dayClasses,
            handleClick: this.handleClick.bind(this),
          }

          let children
          if (!!dayRenderer) {
            children = dayRenderer(props);
          }

          days.push(
            <Day key={i++} {...props}>
              {children}
            </Day>
          );
          current.add(1, 'days');
          if (current.day() === startOfWeekIndex) {
            let weekKey = 'week' + week++;
            elements.push(<Week key={weekKey} schedule_type={this.props.schedule_type}>{days}</Week>);
            days = [];
          }
        }

        let nav

        if (this.props.useNav) {
          nav = (
            <tr className="month-header">
              <th className="nav previous">
                <button className="nav-inner" onClick={this.previous.bind(this)}>
                  &lt;
                </button>
              </th>
              <th colSpan="5">
                <span className="year">
                  {month.locale("ja").format('YYYY年')}
                </span>
                <span className="month">
                  {month.locale("ja").format('MM月')}
                </span>
              </th>
              <th className="nav next">
                <button className="nav-inner" onClick={this.next.bind(this)}>
                  &gt;
                </button>
              </th>
            </tr>
          )
        } else {
          nav = (
            <tr className="month-header">
              <th colSpan="7">
                <span className="month">
                  {month.format('MMMM')}
                </span>
                <span className="year">
                  {month.format('YYYY')}
                </span>
              </th>
            </tr>
          )
        }

        return (
          <table className={classes} onMouseLeave={(e) => this.props.onCalHide()}>
            <thead>
              {nav}
            </thead>
            <thead>
              <tr className="days-header">{daysOfWeek}</tr>
            </thead>
            <tbody>
              {elements}
            </tbody>
          </table>
        );
    }
}

Calendar.propTypes = {
  onSelect: PropTypes.func.isRequired,
  date: PropTypes.object,
  month: PropTypes.object,
  dayClasses: PropTypes.func,
  useNav: PropTypes.bool,
  locale: PropTypes.string,
  startOfWeekIndex: PropTypes.number,
  dayRenderer: PropTypes.func,
  selectType: PropTypes.string
}

Calendar.defaultProps = {
  dayClasses: function() { return [] },
  useNav: true,
  locale: 'ja',
  startOfWeekIndex: 1,
  selectType: 'day'
}
