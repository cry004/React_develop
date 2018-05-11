import React, { Component } from 'react'
import classNames from 'classnames'

export class Subject extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { subject } = this.props
    return(
      <div>
        <h3 className="amazon-subheading">
          {subject.school_name} {subject.subject_name} 授業テキスト
        </h3>
        <div className="amazon-textbooks">
          {subject.workbooks.map((workbook, i) =>
            <a key={i} className="textbook" href={workbook.url} target="_blank">
              <div className="textbook-image">
                <img src={workbook.image.desktop.resource_url} />
              </div>
              <p className="textbook-title">{workbook.name}</p>
            </a>
          )}
        </div>
      </div>
    )
  }
}