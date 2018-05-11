import React, { Component } from 'react'
import classNames from 'classnames'

export class Process extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { checkedSubUnits, editFlag, learning_status, unitIndex, sub_unitIndex, unitsLength, sub_unitsLength, sub_unit_id, curriculumFlag } = this.props
    let topFlag = false
    let bottomFlag = false
    let onFlag = false
    let iconProcess
    let checkBox
    let checkedFlag = false
    if(checkedSubUnits.indexOf(sub_unit_id) > -1) {
      checkedFlag = true
    }
    if(editFlag) {
      checkBox = <div><input type="checkbox" checked={checkedFlag} id={"curriculum_subsubject" + sub_unit_id} onChange={(e) => {this.props.changeCheckedSubUnit(sub_unit_id, e.target.checked)}} /><label htmlFor={"curriculum_subsubject" + sub_unit_id}></label></div>
    }
    if(unitIndex==0 && sub_unitIndex==0) {
      topFlag = true
    }
    if(unitIndex == unitsLength - 1 && sub_unitIndex == sub_unitsLength - 1) {
      bottomFlag = true
    }
    switch(learning_status) {
      case 'pass':
      case 'failure':
        if(curriculumFlag) {
          iconProcess = <i className="icon-process-ok-scheduled" />
        } else {
          iconProcess = <i className="icon-process-ok" />
        }
        onFlag = true
        break;
      case 'sent':
        if(curriculumFlag) {
          iconProcess = <i className="icon-process-ng-scheduled" />
        } else {
          iconProcess = <i className="icon-process-ng" />
        }
        break;
      case 'scheduled':
      case null:
      default:
        if(curriculumFlag) {
          iconProcess = <i className="icon-process-off-scheduled" />
        } else {
          iconProcess = <i className="icon-process-off" />
        }
        break;
    }
    return (
      <div className={classNames('curriculum-process', { on: onFlag, top: topFlag, bottom: bottomFlag })}>
        {checkBox}
        {iconProcess}
      </div>
    )
  }
}