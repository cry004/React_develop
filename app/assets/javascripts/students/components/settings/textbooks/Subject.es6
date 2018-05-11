import React, { Component } from 'react'

import { List } from "./List.es6"

export class Subject extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { subject, selectBook } = this.props
    const cardClass = `card-image is-${subject.key}`
    return(
      <div className="card">
        <div className={cardClass}></div>
          <ul className="card-list">
            {subject.schoolbooks.map((book, k) =>
              <List book={book} key={k} subject={subject.key} selectBook={selectBook} />
            )}
          </ul>
      </div>
    )
  }
}