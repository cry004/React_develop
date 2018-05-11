import React, { Component } from 'react'
import { CurriculumTitle } from '../../components/CurriculumTitle.es6'

export class Unit extends Component{

  constructor(props) {
    super(props)
  }

  render() {
    const { unit, changeCheckedUnit, changeCheckedSubUnit, checkedSubUnits } = this.props
    return(
      <div className="curriculum">
        <CurriculumTitle changeCheckedUnit={changeCheckedUnit} changeCheckedSubUnit={changeCheckedSubUnit} editFlag={true} unit_name={unit.unit_name} unit_id={unit.unit_id} />
        <div className="video">
          {unit.sub_units.map((sub_unit, sub_unitIndex) =>
            <div className="video_name" key={sub_unitIndex}>
              <input checked={checkedSubUnits.indexOf(sub_unit.sub_unit_id)>-1} className="js-unit-checkbox" type="checkbox" id={"curriculum_subsubject" + sub_unit.sub_unit_id} onChange={(e) => {changeCheckedSubUnit(sub_unit.sub_unit_id, e.target.checked)}} />
              <label htmlFor={"curriculum_subsubject" + sub_unit.sub_unit_id}>
                {sub_unit.sub_unit_name}
              </label>
              {sub_unit.videos.map((video, videoIndex) => {
                return <p className="movie_name" key={videoIndex} >
                  {video.video_name}
                </p>
              })}
            </div>
          )}
        </div>
      </div>
    )
  }
}

