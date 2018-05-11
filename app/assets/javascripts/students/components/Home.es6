import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Link } from 'react-router-dom'
import classNames from 'classnames'

import { Header } from './Block/header/Header.es6'
import { Navi } from './Block/navi/Navi.es6'
import { Alert } from './Block/alert/Alert.es6'
import { Popup } from './Block/popup/Popup.es6'
import { Loading } from './Block/loading/Loading.es6'
import { Experience } from './Element/experience/Experience.es6'
import { Pages } from './Pages.es6'

import { updateSearchInput } from '../actions/search.es6'
import { updateScrollLeft } from '../actions/scroll.es6'
import { showPopup } from '../actions/popup.es6'
import { updateLocationHash } from '../actions/locationHash.es6'
import { initScrollLeft } from '../actions/scroll.es6'
import { initHostName } from '../actions/hostname.es6'
import { initUseragentAll } from '../actions/useragent.es6'

class Home extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { dispatch } = this.props
    dispatch(initHostName())
    dispatch(updateLocationHash(window.location.hash.substr(1)))
    dispatch(initScrollLeft())
  }

  componentDidMount() {
    const { useragent, dispatch } = this.props
    dispatch(initUseragentAll())
    if (useragent.isSP === false) {
      window.onscroll = () => {
        dispatch(updateScrollLeft(- window.pageXOffset))
      }
      ga('send', 'pageview', location.hash.split('#')[1])
    }
    window.addEventListener('hashchange', (e) => {
      dispatch(updateLocationHash(window.location.hash.substr(1)))
      window.scroll(0, 0)
      ga('send', 'pageview', location.pathname + location.hash.split('#')[1] + location.search)
    })
  }
  containerClick(e) {
    const { dispatch } = this.props
    dispatch(updateSearchInput(""))
  }
  render() {
    const { popup, createQuestion, scroll, videos, user, search, notifications, accessToken, locationHash, alerts, courses, level, useragent, loading, dispatch } = this.props
    let hash = locationHash.current
    const containerClass = classNames('bl-container', {'is-static': hash === "/terms" || hash === "/commerce_law" })
    const useragentClass = classNames({
      'is-android': useragent.isAndroid,
      'is-ios': useragent.isIOS,
      'is-sp': useragent.isSP,
      'is-tablet': useragent.isTablet
    })
    // FIXME 綺麗にする
    if ( !hash || hash === "/" || hash === "/top" || hash === "/nickname" || hash === "/avatar" || hash === '/commerce_law' && useragent.isSP ||
      hash === '/about' && useragent.isSP ||
      hash === '/terms' && useragent.isSP
    ) {
      return (
        <div className={useragentClass}>
          <Alert scroll={scroll} alerts={alerts} dispatch={dispatch} />
          <Pages />
        </div>
      )
    } else if (hash === "/login" ||
      hash === '/commerce_law' && accessToken.isAccessToken === false ||
      hash === '/about'  && accessToken.isAccessToken === false ||
      hash === '/terms'  && accessToken.isAccessToken === false
      ) {
      return (
        <div>
          <div className="bl-header is-login">
            <Link to="/" className="bl-header-logo"></Link>
          </div>
          <div className="bl-container">
            <Pages />
          </div>
        </div>
      )
    } else {
      return (
        <div onClick={(e) => this.containerClick(e)} className={useragentClass} >
          <Header search={search}
            user={user} 
            notifications={notifications} 
            scroll= {scroll} 
            pathname={hash}
            accessToken={accessToken}
            dispatch={dispatch} />
          <Navi locationHash={locationHash} videos={videos} courses={courses} scroll={scroll} accessToken={accessToken} isInternalMember={user.isInternalMember} dispatch={dispatch} />
          <Alert scroll={scroll} alerts={alerts} dispatch={dispatch} />
          <div className={containerClass}>
            <Loading loading={loading} dispatch={dispatch} />
            <Pages />
          </div>
          <Popup popup={popup} user={user} createQuestion={createQuestion} accessToken={accessToken} locationHash={locationHash} dispatch={dispatch} />
          <Experience level={level} dispatch={dispatch} />
        </div>
     )
    }
  }
}

const mapStateToProps = (state) => {
  return {
    popup: state.popup,
    user: state.user,
    search: state.search,
    scroll: state.scroll,
    notifications: state.notifications,
    accessToken: state.accessToken,
    createQuestion: state.createQuestion,
    locationHash: state.locationHash,
    alerts: state.alerts,
    courses: state.courses,
    level: state.level,
    useragent: state.useragent,
    loading: state.loading,
    videos: state.videos,
    hostname: state.hostname
  }
}

export default connect(mapStateToProps)(Home)