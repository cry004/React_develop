import React, { Component } from 'react' 
import { textImageLoaded } from '../../actions/video.es6'

export class Textbook extends Component {
  constructor(props) {
    super(props)
  }
  imageLoaded() {
    const { video, dispatch } = this.props
    // remove loading if kaisetuWebUrl is null
    if (video.isFetching === false && !video.kaisetuWebUrl) {
      dispatch(textImageLoaded(true))
    }
  }
  render() {
    const { checktestUrl } = this.props
    return(
      <div className="textbook">
        <img src={checktestUrl} 
          onLoad={this.imageLoaded.bind(this)} />
      </div>
    )
  }
}