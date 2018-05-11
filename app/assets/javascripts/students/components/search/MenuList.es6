import React, { Component } from 'react'
import classNames from 'classnames'
import { createMarkup } from '../../util/createMarkup.es6'

export class MenuList extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { unit, index, selectUnits, displayType, selectedUnitIndex } = this.props
    const menuListClass = classNames('menu-list', {
      'is-active': displayType === 'unit' && selectedUnitIndex === index,
      'is-done': unit.completed === true
    })
    const subjectClass = `subject u-color-${unit.name.subject_key}`
    return(
      <a className={menuListClass} onClick={selectUnits.bind(this, unit.title, unit.title_description, unit.schoolbook_id, index)}>
        <span className={subjectClass}>{unit.name.school_name}{unit.name.subject_name} {unit.name.subject_type} {unit.name.subject_detail_name}</span>
        <br />
        <span dangerouslySetInnerHTML={createMarkup(`${unit.title} ${unit.title_description}`)} />
      </a>
    )
  }
}