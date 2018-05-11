import React, { Component } from 'react'

export class CurriculumTitle extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { unit_name, editFlag, unit_id } = this.props
    let contentDom
    if(editFlag) {
      contentDom = <div><input className="js-unit-checkbox" type="checkbox" id={"curriculum_subject" + unit_id} onChange={(e) => {this.props.changeCheckedUnit(unit_id, e.target.checked)}} /><label htmlFor={"curriculum_subject" + unit_id}>{unit_name}</label></div>
    } else {
      contentDom = <h2 className="title">{unit_name}</h2>
    }
    return (
      <div className="curriculum-title">
        {contentDom}
      </div>
    )
  }
}