import React, { Component } from 'react' 
import { textImageLoaded } from '../../actions/video.es6'

export class Commentary extends Component {
  constructor(props) {
    super(props)
  }
  imageLoaded() {
    const { video, dispatch } = this.props
    if (video.isFetching === false) {
      dispatch(textImageLoaded(true))
    }
  }
  render() {
    const { kaisetuWebUrl } = this.props
    return(
      <div className="commentary">
        <iframe src={kaisetuWebUrl} onLoad={this.imageLoaded.bind(this)}></iframe>
      </div>
    )
  }
}