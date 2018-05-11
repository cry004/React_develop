import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Popup } from '../Block/popup/Popup.es6'
import { Card } from './Card.es6'

import { showPopup, hidePopup } from '../../actions/popup.es6'
import { updateVideoId } from '../../actions/video.es6'
import { initHistories, requestHistories } from '../../actions/history.es6'
import { initPager,
  updateCurrentPage } from '../../actions/pager.es6'
import { isShowLoading } from '../../actions/loading.es6'

class History extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(initPager())
    dispatch(initHistories())
    dispatch(updateCurrentPage(1))
    dispatch(requestHistories(accessToken.accessToken , 1))
  }
  // 次回リリース
  // deleteVideo(e, historyId) {
  //   e.stopPropagation()
  //   const { dispatch } = this.props
  //   dispatch(showPopup('history', {
  //     deleteId: historyId
  //   }))
  // }
  componentWillReceiveProps(nextProps) {
    const { history, dispatch } = this.props
    if (history.isFetching === true && nextProps.history.isFetching === false) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false)) 
  }
  selectVideo(videoId) {
    const { dispatch } = this.props
    ga('send', 'event', '視聴履歴に表示される授業', 'click', 'pc_history_eizojugyo_click', 1)
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  updatePage() {
    const { history, pager, accessToken, dispatch } = this.props
    if (history.isFetching === false) {
      dispatch(requestHistories(accessToken.accessToken , pager.currentPage + 1))
    }
  }
  render() {
    const { history, pager, popup, dispatch } = this.props
    if (history.videos.length < 1) {
      return (
        <p className="el-text-nocontent no-header">まだ視聴履歴がありません。</p>
      )
    } else {
      return (
        <div className="page-history">
          {history.videos.map((video, i) =>
            <Card video={video} selectVideo={this.selectVideo.bind(this)} key={i} />
          )}
          {(() => {
            if (pager.isLastPage === false) {
              return (
                <a className="el-button is-white" onClick={() => this.updatePage()}>もっと見る</a>
              )
            }
          })()}
        </div>
      )
    }
  }
}

const mapStateToProps = (state) => {
  return {
    history: state.history,
    popup: state.popup,
    accessToken: state.accessToken,
    pager: state.pager
  }
}

export default connect(mapStateToProps)(History);