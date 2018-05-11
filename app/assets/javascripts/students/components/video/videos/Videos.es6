import React, { Component } from 'react' 

import { Video } from './Video.es6'

export class Videos extends Component {
  constructor(props) {
    super(props)
  }
  render() {
    const { nextVideos, previousVideos, watchOtherVideo} = this.props
    let nexts = nextVideos.concat() //copy
    if (nexts.length > 0) {
      nexts.shift()
    }
    return(
      <div className="videos">
        {nextVideos.length > 0 &&
          <div className="videos-section">
            <p className="label">
              次の授業
            </p>
            <Video video={nextVideos[0]} watchOtherVideo={watchOtherVideo} type="next" index={1} />
          </div>
        }
        <div className="videos-section">
          <p className="label">
            前後の授業
          </p>
          {nexts.map((video, i) =>
            <Video video={video} key={i} watchOtherVideo={watchOtherVideo} type="next" index={i+2} />
          )}
          {previousVideos.map((video, i) =>
            <Video video={video} key={i} watchOtherVideo={watchOtherVideo} type="prev" index={i+1} />
          )}
        </div>
      </div>
    )
  }
}