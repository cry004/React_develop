import React, { Component } from 'react'
import classNames from 'classnames'
import moment from 'moment'

import { SettingBtn } from '../components/SettingBtn.es6'
import { Process } from '../components/Process.es6'
import { CurriculumTitle } from '../components/CurriculumTitle.es6'
import { Btns } from '../components/Btns.es6'

export class Curriculums extends Component {

  constructor(props) {
    super(props)
  }

  returnCurContainerClass(sb_unit_id) {
    let curContainerClass
    let hasIdFlag = false
    this.props.learnings.todo_learning_ids.map((id) => {
      if(id == sb_unit_id) {
        hasIdFlag = true
      }
    })
    curContainerClass = classNames('curriculum-container', { 'blue': hasIdFlag })
    return curContainerClass
  }

  returnLearnedAtText(learned_at) {
    if(learned_at) {
      return `授業設定日：${moment(learned_at).format('YYYY/MM/DD')}`
    } else {
      return ''
    }
  }

  render() {
    const { learnings, editFlag, checkedSubUnits, changeCheckedUnit } = this.props
    let units = learnings.units
    if(!units) {
      units = []
    }
    return (
      <div className="curriculum-contents">
        {units.map((unit, unitIndex) =>
          <div className="curriculum" key={unitIndex}>
            <CurriculumTitle changeCheckedUnit={changeCheckedUnit} editFlag={editFlag} unit_name={unit.unit_name} unit_id={unit.unit_id} />
            {unit.sub_units.map((sub_unit, sub_unitIndex) =>
              <div className={this.returnCurContainerClass(sub_unit.sub_unit_id)} key={sub_unitIndex}>
                <Process
                editFlag={this.props.editFlag}
                learning_status={sub_unit.learning_status}
                unitIndex={unitIndex}
                sub_unitIndex={sub_unitIndex}
                unitsLength={units.length}
                sub_unitsLength={unit.sub_units.length}
                sub_unit_id={sub_unit.sub_unit_id}
                changeCheckedSubUnit={this.props.changeCheckedSubUnit}
                checkedSubUnits={checkedSubUnits}
                curriculumFlag={sub_unit.curriculum_flag} />
                <div className="curriculum-info">
                  <p className="end_date">{this.returnLearnedAtText(sub_unit.learned_at)}</p>
                  <p className="title">
                    {sub_unit.sub_unit_name}
                    {(() => {
                      if (sub_unit.total_duration !== 0 && learnings.entrance_exam_flag === false ) {
                      return <span>（{Math.floor(sub_unit.total_duration / 60)}分)</span>;
                      }
                    })()}
                  </p>

                  <div className="caption">{sub_unit.sub_unit_goals.map((goal,i) =>
                    <p key={i}>{goal}</p>
                  )}</div>
                  {sub_unit.videos.map((video, videoIndex) => {
                    return <Btns editFlag={editFlag} video={video} videoIndex={videoIndex} setYoutubeURL={this.props.setYoutubeURL.bind(this)} key={videoIndex} />
                    }
                  )}
                </div>
                <div className="curriculum-settings">
                  <SettingBtn editFlag={editFlag}
                  learning_status={sub_unit.learning_status}
                  learning_id={sub_unit.learning_id}
                  box_id={sub_unit.box_id}
                  sent_on={sub_unit.sent_on}
                  sub_unit_id={sub_unit.sub_unit_id}
                  curriculum_id={this.props.curriculum_id}
                  student_id={this.props.student_id}
                  period_id={this.props.period_id}
                  onSetLearning={this.props.onSetLearning}
                  main_box_id={this.props.box_id}
                   />
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    )
  }
}
