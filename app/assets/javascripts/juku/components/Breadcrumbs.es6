import React, { Component } from 'react'
import { Link } from 'react-router-dom'

export class Breadcrumbs extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { items } = this.props
    const breadcrumbs = items.map((item, i) => {
      if( item.invisible ){
        return
      } else {
        if (!item.url) {
          return <li className="Breadcrumbs__list-item" key={i}>{item.label}</li>
        }
        return <li className="Breadcrumbs__list-item" key={i}><Link to={item.url}>{item.label}</Link></li>
      }
    })
    return (
      <div className="Breadcrumbs">
        <ul className="Breadcrumbs__list">
          {breadcrumbs}
        </ul>
      </div>
    )
  }
}
