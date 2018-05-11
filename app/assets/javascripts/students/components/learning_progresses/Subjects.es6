import React, { Component } from 'react'

import { Tab } from '../Element/tab/Tab.es6'

export class Subjects extends Component {
  constructor(props) {
    super(props)
  }
  isCurrentPage(url) {
    if (this.state._currentTab === url) {
      return true
    }
    return false
  }
  render() {
    const { changeSubject, isCurrentPage } = this.props
    return(
      <div className="bl-tab">
        <Tab text="最近よく学習している科目" 
          clickFunc={changeSubject.bind(this, 'recent')} 
          isActive={isCurrentPage('recent')} />
        <Tab text="英語" 
          clickFunc={changeSubject.bind(this, 'english')}
          isActive={isCurrentPage('english')} />
        <Tab text="数学" 
          clickFunc={changeSubject.bind(this, 'mathematics')}
          isActive={isCurrentPage('mathematics')} />
        <Tab text="理科" 
          clickFunc={changeSubject.bind(this, 'science')}
          isActive={isCurrentPage('science')} />
        <Tab text="社会" 
          clickFunc={changeSubject.bind(this, 'social_studies')}
          isActive={isCurrentPage('social_studies')} />
        <Tab text="国語" 
          clickFunc={changeSubject.bind(this, 'japanese')}
          isActive={isCurrentPage('japanese')} />
      </div>
    )
  }
}