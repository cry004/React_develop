import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Subject } from './subjects/Subjects.es6'
import { requestWorkbooks } from '../../actions/workbooks.es6'

class Workbooks extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestWorkbooks(accessToken.accessToken))
  }

  render() {
    const { workbooks } = this.props
    return (
      <div className="page-workbooks">
        <div className="top">
        </div>
        <div className="about u-clearfix">
          <div className="about-text u-left">
            <h2 className="about-text-heading">授業テキストとは？</h2>
            <p className="about-text-description">
              映像授業に必携！
              <br/>
              「授業についていけない。」「授業の理解が定着しているかわからない。」
              <br/>
              そんな悩みに応える、授業とともに手を動かしながら理解の定着をはかることができるテキストです。
            </p>
          </div>
        </div>
        
        <div className="amazon">
          <h2 className="amazon-heading">授業テキストはAmazonでご購入いただけます。</h2>
          <p className="amazon-description">
            授業テキストをクリックすると、Amazon.co.jpに遷移します。
          </p>
          {workbooks.subjects.map((subject, i) =>
            <Subject subject={subject} key={i} />
          )}
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    workbooks: state.workbooks
  }
}

export default connect(mapStateToProps)(Workbooks);