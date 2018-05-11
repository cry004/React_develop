import React, { Component } from 'react'

export class PostQuestion extends Component {
    constructor(props) {
    super(props)
  }
  prevPage() {
    const { hidePopup, locationHash} = this.props
    hidePopup()
    window.location.hash = locationHash.prev
  }
  render() {
    const { locationHash } = this.props
    return (
      <div className="post-question">
        <p>
          質問を送信しました。
          <br/>
          (質問は添削指導に追加されます)
        </p>
        <a className="el-button size-small is-blue" onClick={()=>this.prevPage()}>OK</a>
      </div>
    )
  }
}