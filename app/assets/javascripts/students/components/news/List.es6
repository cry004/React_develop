import React, { Component } from 'react'
import classNames from 'classnames'

import { requestNewsDetail } from '../../actions/news.es6'

export class List extends Component {
  constructor(props) {
    super(props)
  }
  updateCurrentNews(id) {
    const { accessToken, dispatch } = this.props
    dispatch(requestNewsDetail(accessToken.accessToken , id))
  }

  render() {
    const { news, currentId } = this.props
    const listClass = classNames('news-list u-clearfix', {'is-unread': news.unread === true, 'is-active': news.id === currentId})
    return(
      <li className={listClass} onClick={()=> this.updateCurrentNews(news.id)}>
        <div className="news-list-image u-left"></div>
        <div className="news-list-text u-left">
          <p className="news-list-text-content">
            {news.title}
          </p>
          <time className="news-list-text-date">{news.date}</time>
        </div>
      </li>
    )
  }
}