import React, { Component } from 'react'
import classNames from 'classnames'

export class Box extends Component {
  constructor(props) {
    super(props)
  }

  boxClick(subject_id) {
    const { box } = this.props
    this.props.onSelect(
      box.student_id,
      box.student_name,
      subject_id,
      box.schoolyear_key,
      box.box_id,
      box.agreement_id,
      box.period_id,
      this.props.date
    )
  }

  render() {
    const { box } = this.props
    return(
      <td className="Schedule__box-item">
        {(() => {
          if( box.box_id){
            return (<div className="Schedule__box-container">
              <div className="studentarea">
                <p className="grade">{box.schoolyear_name}</p>
                <p className="name">{box.student_name}さん</p>
              </div>
              {box.subjects.map((subject, index) =>
                <div className="subjectarea" key={index} onClick={(e) => this.boxClick(subject.subject_id)}>
                  <p className="subject" style={{color: subject.subject_color_code}}>{subject.subject_name}</p>
                  <span className={classNames('config', `${subject.sent_flag}`)}></span>
                </div>
              )}
            </div>)
          } else {
            return <div className="Schedule__box-container"></div>
          }
        })()}
      </td>
    )
  }
}
