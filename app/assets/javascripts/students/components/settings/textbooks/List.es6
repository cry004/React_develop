import React, { Component } from 'react'

export class List extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    const { book, subject, selectBook } = this.props
    return(
      <li>
        <input type="radio" id={book.id} name={subject} onChange={selectBook.bind(this, subject, book.display_name)} checked={book.selected_flag} />
        <label htmlFor={book.id}>
          {book.display_name}
        </label>
      </li>
    )
  }
}