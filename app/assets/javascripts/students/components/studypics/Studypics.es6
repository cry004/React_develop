import React, { Component } from 'react'
import { connect } from 'react-redux'

class StudypicsList extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    return (
      <div className="page-studypics-list">
        <iframe src="https://m.try-it.jp/app_studypics/"></iframe>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(StudypicsList);