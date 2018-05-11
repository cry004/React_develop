import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'
import { createMarkup } from '../../util/createMarkup.es6'

import { MenuList } from './MenuList.es6'
import { Tab } from '../Element/tab/Tab.es6'
import { Video } from '../Element/video/Video.es6'

import { requestSearchWords,
  requestSearchVideos,
  updateSearchGrade,
  requestSearchUnits } from '../../actions/search.es6'
import { updateVideoId } from '../../actions/video.es6'
import { isShowLoading } from '../../actions/loading.es6'
import { updateCurrentPage } from '../../actions/pager.es6'

class Search extends Component {

  constructor(props) {
    super(props)
    this.state = {
      _displayType: 'video', // video or units
      _selectedUnitIndex: null,
      _title: '',
      _titleDescription: ''
    }
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(isShowLoading(true))
    dispatch(updateCurrentPage(1))
    dispatch(requestSearchWords(accessToken.accessToken))
  }
  componentWillReceiveProps(nextProps) {
    const { search, dispatch } = this.props
    if (search.isFetching === true && nextProps.search.isFetching === false) {
      dispatch(isShowLoading(false))
    }
    if (search.keyword !== nextProps.search.keyword) {
      this.setState({
        _displayType: 'video'
      })
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  selectVideo(videoId) {
    const { dispatch } = this.props
    dispatch(updateVideoId(videoId))
    window.location.hash = '/video'
  }
  updateTab(tabName) {
    const { accessToken, search, dispatch } = this.props
    if (tabName === 'c') {
      dispatch(requestSearchVideos(accessToken.accessToken, search.keyword, 1, "c"))
      dispatch(updateSearchGrade("c"))
    } else if (tabName === 'k') {
      dispatch(requestSearchVideos(accessToken.accessToken, search.keyword, 1, "k"))
      dispatch(updateSearchGrade("k"))
    } else {
      dispatch(requestSearchVideos(accessToken.accessToken, search.keyword, 1))
      dispatch(updateSearchGrade("all"))
    }
    this.setState({
      _displayType: 'video'
    })
  }
  isCurrentPage(url) {
    const { search } = this.props
    if (search.grade === url) {
      return true
    }
    return false
  }
  selectUnits(title, titleDescription, schoolbookId, i) {
    const { accessToken, dispatch } = this.props
    this.setState({
      _displayType: 'unit',
      _selectedUnitIndex: i,
      _title: title,
      _titleDescription: titleDescription
    })
    dispatch(requestSearchUnits(accessToken.accessToken, title, titleDescription, schoolbookId))
  }
  selectVideos() {
    this.setState({
      _displayType: 'video'
    }) 
  }

  updatePage() {
    const { search, pager, accessToken, dispatch } = this.props
    if (pager.isLastPage || search.isFetching === true) {
      return false
    }
    if (search.isFetching === false) {
      dispatch(requestSearchVideos(accessToken.accessToken, search.keyword, pager.currentPage + 1,  search.grade === "all" ? "" : search.grade))
    }
  }
  render() {
    const { tab, pager, dispatch, search } = this.props
    const videoCardsClass = classNames('videolist u-left', {'u-hidden': this.state._displayType === 'unit' })
    const unitCardsClass = classNames('videolist u-left', {'u-hidden': this.state._displayType === 'video' })
    const videoMenuListClass = classNames('menu-list is-all', {'is-active': this.state._displayType === 'video'})

    return (
      <div className="page-search">
        <div className="bl-tab">
          <Tab text="すべて" 
            clickFunc={this.updateTab.bind(this, 'all')}
            isActive={this.isCurrentPage('all')} />
          <Tab text="中学版" 
            clickFunc={this.updateTab.bind(this, 'c')}
            isActive={this.isCurrentPage('c')} />
          <Tab text="高校版" 
            clickFunc={this.updateTab.bind(this, 'k')}
            isActive={this.isCurrentPage('k')} />
        </div>
        <div className="container u-clearfix">
          <div className="container-inner">
            <div className="menus u-left">
              <div className="u-clearfix">
                <p className="subheading u-left">授業</p>
                <p className="count u-right">{search.videosCount}件</p>
              </div>
              <div className="menu">
                <p className={videoMenuListClass} onClick={()=> this.selectVideos()}>すべて</p>
              </div>
              <div className="u-clearfix">
                <p className="subheading u-left">章</p>
                <p className="count u-right">{search.units.length}件</p>
              </div>
              <div className="menu">
                {search.units.map((unit, i) =>
                  <MenuList key={i} index={i} unit={unit} selectUnits={this.selectUnits.bind(this)} displayType={this.state._displayType} selectedUnitIndex={this.state._selectedUnitIndex} />
                )}
              </div>
            </div>
            <div className={videoCardsClass}>
              {(() => {
                if (search.videos.length < 1) {
                  return (
                    <p className="el-text-nocontent">検索結果がありません。</p>
                  )
                } else {
                  return (
                    <ul className="cards">
                      {search.videos.map((video, i) =>
                        <li className="el-card u-left" key={i} onClick={() => this.selectVideo(video.video_id)}>
                          <Video video={video} isSubject="true" />
                        </li>
                      )}
                    </ul>
                  )
                }
              })()}
              { pager.isLastPage === false &&
                <a className="el-button size-large is-white" onClick={() => this.updatePage()}>もっと見る</a>
              }
            </div>
            <div className={unitCardsClass}>
              <div className="cards">
                {search.unitVideos.map((video, i) =>
                  <div className="el-card u-left" key={i} onClick={() => this.selectVideo(video.video_id)}>
                    <Video video={video} isSubject="true" />
                  </div>
                )}
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
    tab: state.tab,
    accessToken: state.accessToken,
    search: state.search,
    pager: state.pager
  }
}

export default connect(mapStateToProps)(Search);