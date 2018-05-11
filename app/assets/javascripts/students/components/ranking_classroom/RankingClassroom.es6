import React, { Component } from 'react'
import { connect } from 'react-redux'
import { getPeriodTypeFromHash } from '../../util/string.es6'

import { Tab } from '../Element/tab/Tab.es6'
import { Status } from './Status.es6'
import { Card } from './Card.es6'

import { requestRankingsClassroom,
  requestRankingsClassrooms,
  updateCurrentRankingClassroomTab } from '../../actions/rankingsClassroom.es6'
import { isShowLoading } from '../../actions/loading.es6'

class RankingClassroom extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, locationHash, dispatch } = this.props
    dispatch(isShowLoading(true))
    const periodType = getPeriodTypeFromHash(locationHash.current)
    dispatch(requestRankingsClassrooms(accessToken.accessToken, periodType))
  }
  componentWillReceiveProps(nextProps) {
    const { accessToken, locationHash, rankingClassroom, dispatch } = this.props
    if (rankingClassroom.isFetching === true && nextProps.rankingClassroom.isFetching === false) {
      dispatch(isShowLoading(false))
    } else if (rankingClassroom.isFetching === false && nextProps.rankingClassroom.isFetching === true) {
      dispatch(isShowLoading(true))
    }
    if (locationHash.current !== nextProps.locationHash.current) {
      const periodType = getPeriodTypeFromHash(nextProps.locationHash.current)
      dispatch(requestRankingsClassrooms(accessToken.accessToken, periodType))
    }
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(isShowLoading(false))
  }

  updateTab(classroomType, regionType) {
    const { rankingClassroom, accessToken, dispatch } = this.props
    dispatch(requestRankingsClassroom(accessToken.accessToken, regionType, rankingClassroom.currentTerm || 'last_7_days', classroomType)) 
    dispatch(updateCurrentRankingClassroomTab({
      classroomType: classroomType,
      regionType: regionType
    }))
  }
  isCurrentPage(classroomType, regionType) {
    const { rankingClassroom } = this.props
    if (rankingClassroom.currentTab.classroomType === classroomType 
      && rankingClassroom.currentTab.regionType === regionType) {
      return true
    }
    return false
  }
  render() {
    const { rankingClassroom } = this.props
    const termText = rankingClassroom.currentTerm === 'last_7_days' ? '過去7日間' : `${rankingClassroom.rankingMonth}月`
    return (
      <div className="page-ranking is-classroom">
        <div className="top">
          <h1 className="heading">教室/校舎ランキング　{termText}</h1>
          <p className="term">集計期間 {rankingClassroom.rankingDate.start} - {rankingClassroom.rankingDate.end}</p>
        </div>
        {rankingClassroom.classroom.id &&
          <Status classroom={rankingClassroom.classroom} learningTime={rankingClassroom.learningTime} currentClassroomRankings={rankingClassroom.currentClassroomRankings} rankingChanges={rankingClassroom.rankingChanges} classroomType={rankingClassroom.classroom.type} rankingMonth={rankingClassroom.rankingMonth}
            currentTerm={rankingClassroom.currentTerm} />
        }
        <div className="bl-tab">
          {rankingClassroom.classroom.type === 'classroom' &&
            <Tab text={`教室 ${rankingClassroom.classroom.prefecture_name}`}
              clickFunc={this.updateTab.bind(this, 'classroom', 'prefecture')} 
              isActive={this.isCurrentPage('classroom', 'prefecture')} />
          }
          <Tab text="教室 全国"
            clickFunc={this.updateTab.bind(this, 'classroom', 'national')} 
            isActive={this.isCurrentPage('classroom', 'national')} />
          <Tab text="校舎 全国"
            clickFunc={this.updateTab.bind(this, 'schoolhouse', 'national')}
            isActive={this.isCurrentPage('schoolhouse', 'national')} />
        </div>
        {(() => {
          if (rankingClassroom.rankings.length < 1) {
            return (
              <p className="el-text-nocontent">まだランキングがありません。</p>
            )
          } else {
            return (
              <div className="cards u-clearfix">
                {rankingClassroom.rankings.map((card, j) =>
                  <Card ranking={card} rank={j+1} key={j} currentTab={rankingClassroom.currentTab} />
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
    rankingClassroom: state.rankingClassroom,
    accessToken: state.accessToken,
    locationHash: state.locationHash
  }
}

export default connect(mapStateToProps)(RankingClassroom);