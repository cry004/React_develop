import React, { Component } from 'react'
import classNames from 'classnames'

export class RankingMenu extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { isActive, onClickRanking } = this.props
    const linkClass = isActive === true ? 'is-active' : ''
    return (
      <li className="bl-tab-list is-ranking">
        <a className={linkClass} >
          ランキング
        </a>
        <ul className="bl-tab-list-subject">
          <li onClick={onClickRanking.bind(this, 'personal', 'last_7_days')}>
            <a>
              個人ランキング 過去7日間
            </a>
          </li>
          <li onClick={onClickRanking.bind(this, 'classroom', 'last_7_days')}>
            <a>
              教室/校舎ランキング 過去7日間
            </a>
          </li>
          <li onClick={onClickRanking.bind(this, 'personal', 'last_month')}>
            <a>
              個人ランキング 月間
            </a>
          </li>
          <li onClick={onClickRanking.bind(this, 'classroom', 'last_month')}>
            <a>
              教室/校舎ランキング 月間
            </a>
          </li>
        </ul>
      </li>
    )
  }
}