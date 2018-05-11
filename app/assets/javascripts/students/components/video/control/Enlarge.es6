import React, { Component } from 'react' 

import { updateIsEnlarged } from '../../../actions/video.es6'

export class Enlarge extends Component {
  constructor(props) {
    super(props)
  }

  toggleEnlarged() {
    const { isEnlarged, dispatch } = this.props
    if (isEnlarged === true) {
      dispatch(updateIsEnlarged(false))
    } else {
      dispatch(updateIsEnlarged(true))
    }
  }

  render() {
    return(
      <a className="video-control-screen u-left" onClick={() => this.toggleEnlarged()}></a>
    )
  }
}