import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { List } from './List.es6'

import { requestNews,
  currentNewsId,
  initNews,
  requestNewsDetail } from '../../actions/news.es6'
import { updateCurrentPage } from '../../actions/pager.es6'
import { isShowLoading } from '../../actions/loading.es6'

class News extends Component {

  constructor(props) {
    super(props)
    this.setTimoutId = null
  }
  componentWillMount() {
    const { accessToken, news, dispatch } = this.props
    dispatch(initNews())
    dispatch(isShowLoading(true))
    dispatch(updateCurrentPage(1))
    if (news.currentId === null) {
      dispatch(requestNews(accessToken.accessToken , null, 20, true))
    } else if (!!news.currentId) {
      dispatch(requestNews(accessToken.accessToken , null, 20, false))
      dispatch(requestNewsDetail(accessToken.accessToken , news.currentId))
    }
  }
  componentDidMount() {
    this.listDom.addEventListener("scroll", this.requestNextPage.bind(this))
  }
  componentDidUpdate() {
    const { pager } = this.props
    if (pager.isLastPage === true) {
      this.listDom.removeEventListener("scroll", this.requestNextPage.bind(this))
    }
  }
  componentWillReceiveProps(nextProps) {
    const { accessToken, news, dispatch } = this.props
    if (news.currentId !== nextProps.news.currentId) {
      dispatch(requestNewsDetail(accessToken.accessToken, nextProps.news.currentId))
    }
    if (news.isFetching === true && nextProps.news.isFetching === false) {
      dispatch(isShowLoading(false))
    }
    if (news.isListFetching === false && nextProps.news.isListFetching && nextProps.news.news.length === 0) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { news, dispatch } = this.props
    if (!!news.news[0]) {
      dispatch(currentNewsId(news.news[0].id))
    }
    dispatch(isShowLoading(false)) 
  }

  requestNextPage() {
    const { accessToken, pager, news, dispatch } = this.props
    if (pager.isLastPage || news.isListFetching) {
      return false;
    }
    const MENU_HEIGHT = this.listDom.clientHeight
    const THRESHOLD = 100 //一番下から${THRESHOLD}px上までスクロールされた次を読み込む
    let self = this
    if (this.setTimeoutId) {
      return false
    }
    let maxId = news.news[news.news.length-1]['id']
    this.setTimeoutId = setTimeout(() => {
      if (self.listDom.scrollTop + MENU_HEIGHT + THRESHOLD > self.listDom.scrollHeight) {
        dispatch(requestNews(accessToken.accessToken , maxId, 20))
      }
      self.setTimeoutId = null
    }, 100)
  }
  createMarkup(str) {
    let text = str.replace(/\\n/g, '<br>')
    return {
      __html: text
    } 
  }
  render() {
    const { news, accessToken, dispatch } = this.props
    const noContentClass = classNames('el-text-nocontent', { 'u-hidden' : news.news.length > 0 })
    const contentClass = classNames('u-clearfix', { 'u-hidden' : news.news.length < 1})
    return (
      <div className="page-news">
        <div className="container">
          <h1 className="heading">トライからのお知らせ</h1>
          <p className={noContentClass}>まだお知らせがありません。</p>
          <div className={contentClass}>
            <ul className="news u-left" ref={(list) => this.listDom = list}>
              {news.news.map((news, index) =>
                <List key={index} news={news} accessToken={accessToken} currentId={news.currentId} dispatch={dispatch} />
              )}
            </ul>
            <div className="main u-left">
              <div className="main-heading">
                {news.currentNews.imageUrl &&
                  <img className="main-heading-image" src={news.currentNews.imageUrl}/>
                }
                <h1 className="main-heading-title">
                  {news.currentNews.title}
                </h1>
                <time className="main-heading-date">{news.currentNews.date}</time>
              </div>
              <div className="main-content">
                <div dangerouslySetInnerHTML={this.createMarkup(news.currentNews.content)} />
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    news: state.news,
    pager: state.pager
  }
}

export default connect(mapStateToProps)(News);