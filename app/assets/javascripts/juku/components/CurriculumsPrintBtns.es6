import React, { Component } from 'react'
import classNames from 'classnames'

export class CurriculumsPrintBtns extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    let disableFlag = false
    let sentLen = 0
    if(this.props.learnings.units) {
      this.props.learnings.units.map(unit =>
        unit.sub_units.map(sub_unit => {
          if(sub_unit.learning_status == 'sent' && sub_unit.box_id == +this.props.box_id){ sentLen++ }
        })
      )
    }
    if(sentLen == 0) {
      disableFlag = true
    }
    let printBtnClass = classNames('el-button color-white icon-print', {'color-disabled': disableFlag})
    let reportBtnClass = classNames('el-button color-pink icon-print', {'color-disabled': disableFlag})
    let longBtn = { width: 285 +'px', paddingLeft: 30 + 'px'}
    return (
      <div className="Curriculums__header-right">
        <input type="button" className={reportBtnClass} value="授業内容を確定する" onClick={this.props.onPostLearningReport} disabled={disableFlag} />
      </div>
    )
  }
}
