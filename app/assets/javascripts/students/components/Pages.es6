import React, { Component } from 'react'
import { Route, Switch } from 'react-router-dom'

import Login from '../components/login/Login.es6'
import Videos from '../components/videos/Videos.es6'
import Video from '../components/video/Video.es6'
import CreateQuestion from '../components/create_question/CreateQuestion.es6'
import Question from '../components/question/Question.es6'
import Top from '../components/top/Top.es6'
import LearningProgresses from '../components/learning_progresses/LearningProgresses.es6'
import News from '../components/news/News.es6'
import History from '../components/history/History.es6'
import Questions from '../components/questions/Questions.es6'
import Studypics from '../components/studypics/Studypics.es6'
import Terms from '../components/terms/Terms.es6'
import Nickname from '../components/nickname/Nickname.es6'
import Avatar from '../components/avatar/Avatar.es6'
import CommerceLaw from '../components/commerce_law/CommerceLaw.es6'
import Search from '../components/search/Search.es6'
import SettingsPrivacy from '../components/settings/privacy/Privacy.es6'
import SettingsTextbooks from '../components/settings/textbooks/Textbooks.es6'
import SettingsProfile from '../components/settings/profile/Profile.es6'
import Workbooks from '../components/workbooks/Workbooks.es6'
import About from '../components/about/About.es6'
import Bookmark from '../components/bookmark/Bookmark.es6'
import Teacher from '../components/teacher/Teacher.es6'
import Jiritsu from '../components/jiritsu/Jiritsu.es6'
import Ranking from '../components/ranking/Ranking.es6'
import RankingClassroom from '../components/ranking_classroom/RankingClassroom.es6'

export class Pages extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    return(
      <Switch>
        <Route exact path="/" component={Top} />
        <Route exact path="/nickname" component={Nickname} />
        <Route exact path="/avatar" component={Avatar} />
        <Route exact path="/login" component={Login} />
        <Route exact path="/video" component={Video} />
        <Route exact path="/videos" component={Videos} />
        <Route exact path="/create_question" component={CreateQuestion} />
        <Route exact path="/question" component={Question} />
        <Route exact path="/learning_progresses" component={LearningProgresses} />
        <Route exact path="/news" component={News} />
        <Route exact path="/history" component={History} />
        <Route exact path="/questions" component={Questions} />
        <Route exact path="/studypics" component={Studypics} />
        <Route exact path="/terms" component={Terms} />
        <Route exact path="/commerce_law" component={CommerceLaw} />
        <Route exact path="/search" component={Search} />
        <Route exact path="/settings_privacy" component={SettingsPrivacy} />
        <Route exact path="/settings_textbooks" component={SettingsTextbooks} />
        <Route exact path="/settings_profile" component={SettingsProfile} />
        <Route exact path="/workbooks" component={Workbooks} />
        <Route exact path="/about" component={About} />
        <Route exact path="/bookmark" component={Bookmark} />
        <Route exact path="/teacher" component={Teacher} />
        <Route exact path="/jiritsu" component={Jiritsu} />
        <Route exact path="/ranking" component={Ranking} />
        <Route exact path="/ranking_classroom" component={RankingClassroom} />
      </Switch>
    )
  }
}