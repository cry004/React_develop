import React, { Component } from 'react'
import { connect } from 'react-redux'
import { getPeriodTypeFromHash } from '../../util/string.es6'

import { Tab } from '../Element/tab/Tab.es6'
import { Status } from './Status.es6'
import { Card } from './Card.es6'

import { requestRankingsPersonal,
  requestRankingsPersonals,
  updateCurrentRankingTab } from '../../actions/rankings.es6'
import { isShowLoading } from '../../actions/loading.es6'

class Ranking extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, locationHash, dispatch } = this.props
    dispatch(isShowLoading(true))
    const periodType = getPeriodTypeFromHash(locationHash.current)
    dispatch(requestRankingsPersonals(accessToken.accessToken, periodType))
  }
  componentWillReceiveProps(nextProps) {
    const { locationHash, accessToken, ranking, dispatch } = this.props
    if (ranking.isFetching === true && nextProps.ranking.isFetching === false) {
      dispatch(isShowLoading(false))
    } else if (ranking.isFetching === false && nextProps.ranking.isFetching === true) {
      dispatch(isShowLoading(true))
    }
    if (locationHash.current !== nextProps.locationHash.current) {
      const periodType = getPeriodTypeFromHash(nextProps.locationHash.current)
      dispatch(requestRankingsPersonals(accessToken.accessToken, periodType))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  updateTab(type) {
    const { ranking, accessToken, dispatch } = this.props
    dispatch(updateCurrentRankingTab(type))
    dispatch(requestRankingsPersonal(accessToken.accessToken, type, ranking.currentTerm || 'last_7_days'))
  }
  isCurrentPage(type) {
    const { ranking } = this.props
    if (ranking.currentTab === type) {
      return true
    }
    return false
  }
  render() {
    const { ranking } = this.props
    const termText = ranking.currentTerm === 'last_7_days' ? '過去7日間' : `${ranking.rankingMonth}月`
    return (
      <div className="page-ranking">
        <div className="top">
          <h1 className="heading">個人ランキング　{termText}</h1>
          <p className="term">集計期間 {ranking.rankingDate.start} - {ranking.rankingDate.end}</p>
        </div>
        <Status student={ranking.student} learningTime={ranking.learningTime} currentStudentRankings={ranking.currentStudentRankings} rankingChanges={ranking.rankingChanges} 
          rankingMonth={ranking.rankingMonth} 
          currentTerm={ranking.currentTerm}
        />
        <div className="bl-tab">
          {ranking.student.classroom_type === 'classroom' &&
            <Tab text="教室"
              clickFunc={this.updateTab.bind(this, 'classroom')} 
              isActive={this.isCurrentPage('classroom')} 
            />
          }
          {ranking.student.classroom_type === 'schoolhouse' &&
            <Tab text="校舎"
              clickFunc={this.updateTab.bind(this, 'schoolhouse')} 
              isActive={this.isCurrentPage('schoolhouse')} 
            />
          }
          <Tab text={ranking.student.school_address}
            clickFunc={this.updateTab.bind(this, 'prefecture')} 
            isActive={this.isCurrentPage('prefecture')} />
          <Tab text="全国" 
            clickFunc={this.updateTab.bind(this, 'national')} 
            isActive={this.isCurrentPage('national')} />
        </div>
        {(() => {
          if (ranking.rankings.length < 1) {
            return (
              <p className="el-text-nocontent">まだランキングがありません。</p>
            )
          } else {
            return (
              <div className="cards u-clearfix">
                {ranking.rankings.map((card, j) =>
                  <Card ranking={card} rank={j+1} key={j} currentTab={ranking.currentTab} />
                )}
              </div>
            )
          }
        })()}
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    ranking: state.ranking,
    accessToken: state.accessToken,
    locationHash: state.locationHash
  }
}

export default connect(mapStateToProps)(Ranking);