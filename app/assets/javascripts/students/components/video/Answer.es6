import React, { Component } from 'react' 

export class Answer extends Component {
  constructor(props) {
    super(props)
  }

  render() {
    const { answerUrl } = this.props
    return(
      <div className="answer">
        <img src={answerUrl} />
      </div>
    )
  }
}