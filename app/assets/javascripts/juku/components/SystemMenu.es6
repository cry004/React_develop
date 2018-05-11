import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import classNames from 'classnames'

export class SystemMenu extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const scheduleClass = classNames({'active': (this.props.pathname === '/schedule')})
    const studentsClass = classNames({'active': (this.props.pathname === '/students')}) 
    const simulatorClass = classNames({'active': (this.props.pathname === '/simulator')})
    return (
      <div className="SystemMenu">
        <ul className="SystemMenu__list">
          <li className="SystemMenu__list-item"><Link to="/schedule" className={scheduleClass}>授業設定</Link></li>
          <li className="SystemMenu__list-item"><Link to="/students" className={studentsClass}>生徒一覧</Link></li>
          <li className="SystemMenu__list-item"><Link to="/simulator" className={simulatorClass}>カリキュラムシミュレーター</Link></li>
        </ul>
      </div>
    )
  }
}