import React, { Component } from 'react'

export class ReportInfo extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { curriculum } = this.props

    let info
    let curriculumStatusPer
    let statusBarStyle

    if(curriculum.curriculum_id != null) {
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
      statusBarStyle = {width: statusBarStylePer + "%"}
      info = <div className="Report__status">
        <div className="Report__status-subject">
        {curriculum.learnings.sub_subject_name}
        </div>
        <div className="Report__status-process">
          <div className="curriculum_target">
            <h4 className="curriculum_label">目標</h4>
            <p className="curriculum_target-text">{curriculum.start_date}から{curriculum.end_date}までに、<br />
            <strong>{curriculum.learnings.first_learning_title}</strong>から<strong>{curriculum.learnings.last_learning_title}</strong>までの全<strong>{curriculum.scheduled_count}本</strong>の学習を完了する。</p>
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
            <p className="complete"><span className="movie_num">{curriculum.learned_count}</span><span className="slush">/</span>{curriculum.scheduled_count}本</p>
          </div>
          </div>
          </div>
        </div>
    } else {
      if(curriculum.learnings.learnings_count <= 0) {
        curriculumStatusPer = 0
      } else {
        curriculumStatusPer = Math.floor(curriculum.learnings.learned_count / curriculum.learnings.learnings_count * 100)
      }
      let statusBarStylePer
      if(curriculumStatusPer > 100) {
        statusBarStylePer = 100
      } else {
        statusBarStylePer = curriculumStatusPer
      }
      statusBarStyle = {width: statusBarStylePer + "%"}
      info = <div className="Report__status">
        <div className="Report__status-subject">
          {curriculum.learnings.sub_subject_name}
        </div>
        <div className="Report__status-process">
          <span className="title">学習済</span>
          <br />
          <span className="num"><span className="big">{curriculum.learnings.learned_count}/</span>{curriculum.learnings.learnings_count}本</span>
        </div>
        <div className="Report__status-bar"><div className="bar"><div className="bar-content" style={statusBarStyle}></div></div><div className="bar-per">{curriculum.learnings.learnings_count}本</div></div>
      </div>
    }
    return (
      <div>
        {info}
      </div>
    )
  }
}
