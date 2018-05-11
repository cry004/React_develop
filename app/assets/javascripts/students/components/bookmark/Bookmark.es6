import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Video } from '../Element/video/Video.es6'

import { showPopup } from '../../actions/popup.es6'
import { updateVideoId } from '../../actions/video.es6'
import { initBookmarks,
  requestBookmarks } from '../../actions/bookmark.es6'
import { updateCurrentPage } from '../../actions/pager.es6'
import { isShowLoading } from '../../actions/loading.es6'

class Bookmark extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(initBookmarks())
    dispatch(updateCurrentPage(1))
    dispatch(requestBookmarks(accessToken.accessToken, null))
  }
  componentWillReceiveProps(nextProps) {
    const { bookmark, dispatch } = this.props
    if (bookmark.isFetching === true && nextProps.bookmark.isFetching === false) {
      dispatch(isShowLoading(false))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false)) 
  }

  showPopup(e, videoId) {
    const { dispatch } = this.props
    e.stopPropagation()
    dispatch(showPopup('bookmark', {
      deleteId: videoId
    }))
  }
  selectVideo(videoId) {
    const { dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  updatePage() {
    const { bookmark, accessToken, dispatch } = this.props
    if (bookmark.isFetching === false) {
      let maxId = bookmark.videos[bookmark.videos.length-1]['video_id']
      dispatch(requestBookmarks(accessToken.accessToken , maxId))
    }
  }

  render() {
    const { bookmark, pager } = this.props
    if (bookmark.videos.length < 1) {
      return (
        <p className="el-text-nocontent no-header">まだブックマークがありません。</p>
      )
    } else {
      return (
        <div className="page-bookmark">
          {bookmark.videos.map((video, i) =>
            <div className="el-card" key={i} onClick={() => this.selectVideo(video.video_id)}>
              <a className="el-card-close" onClick={(e) => this.showPopup(e, video.video_id)}>
              </a>
              <Video video={video} isSubject="true" />
            </div>
          )}
          {(() => {
            if (pager.isLastPage === false) {
              return (
                <a className="el-button size-large is-white" onClick={() => this.updatePage()}>もっと見る</a>
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
    bookmark: state.bookmark,
    accessToken: state.accessToken,
    pager: state.pager
  }
}

export default connect(mapStateToProps)(Bookmark);