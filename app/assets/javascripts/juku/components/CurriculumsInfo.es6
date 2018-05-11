import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import moment from 'moment'

import { ResetModal } from '../components/ResetModal.es6'
import { setResetModal } from '../actions/Curriculums.es6'

export class CurriculumsInfo extends Component {

  constructor(props) {
    super(props)
  }

  openResetModal(e) {
    const { dispatch } = this.props
    dispatch(setResetModal(true))
  }

  closeResetModal(e) {
    const { dispatch } = this.props
    dispatch(setResetModal(false))
  }

  render() {
    const { curriculum, agreement, learnings, selected_sub_subject_name } = this.props
    let info2
    let info3
    let curriculumStatusPer
    if(curriculum.scheduled_count <= 0) {
      curriculumStatusPer = 0
    } else {
      curriculumStatusPer = Math.floor(curriculum.learned_count / curriculum.scheduled_count * 100)
    }

    let statusBarStylePer
    if(curriculumStatusPer > 100) {
      statusBarStylePer = 100
    } else {
      statusBarStylePer = curriculumStatusPer
    }
    let statusBarStyle = { width: statusBarStylePer + "%" }

    if(!Object.keys(curriculum).length) {
      info2 = <div className="grade_subject">
            {selected_sub_subject_name}
            <Link to="/edit" className="edit">カリキュラムを設定する</Link>
          </div>
      info3 = <div className="info-3 right">
          <div className="curriculum_status-container">
            <div className="curriculum_complete">
              <p className="title">学習済</p>
              <p className="complete">
                <span className="movie_num">{learnings.learned_count}</span>
                <span className="slush">/</span>
                {learnings.learnings_count}
                本
              </p>
            </div>
          </div>
        </div>
    } else {
      info2 = <div className="grade_subject">
          {selected_sub_subject_name}
          <a className="edit" onClick={this.openResetModal.bind(this)}>カリキュラムを再設定する</a>
        </div>
      info3 = <div className="info-3 right">
          <div className="curriculum_target">
            <h4 className="curriculum_label">目標</h4>
            <p className="curriculum_target-text">
              {moment(curriculum.start_date).format('YYYY年MM月DD日')}から{moment(curriculum.end_date).format('YYYY年MM月DD日')}までに、
              <br />
              <strong>{learnings.first_learning_title}</strong>
              から
              <strong>{learnings.last_learning_title}</strong>
              までの全
              <strong>{curriculum.scheduled_count}本</strong>
              の学習を完了する。
            </p>
          </div>
          <div className="curriculum_status-container">
            <h4 className="curriculum_label">進度</h4>
            <div className="curriculum_status">
              <div className="curriculum_status-header">
                <div className="curriculum_status-per">{curriculumStatusPer}%</div>
              </div>
              <div className="curriculum_status-content">
                <div className="curriculum_status-bar">
                  <div className="curriculum_status-bar-content" style={statusBarStyle} />
                </div>
              </div>
            </div>
            <div className="curriculum_complete">
              <p className="complete">
                <span className="movie_num">{curriculum.learned_count}</span>
                <span className="slush">/</span>{curriculum.scheduled_count}本
              </p>
            </div>
          </div>
        </div>
    }
    return(
      <div className="Curriculums-info">
        <div className="info-1">
          <div className="subject">{agreement.subject_name}</div>
        </div>
        <div className="info-2">
          <div className="info-2-container">
            {info2}
          </div>
        </div>
        {info3}
        <ResetModal isActive={this.props.isActive} onClose={this.closeResetModal.bind(this)} />
      </div>
    )
  }
}
