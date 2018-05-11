import React, { Component } from 'react'
import { connect } from 'react-redux'

import { requestPrivacySettings,
  updatePrivateFlag } from '../../../actions/user.es6'

class SettingsPrivacy extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestPrivacySettings(accessToken.accessToken))
  }
  updateChceckbox() {
    const { user, accessToken, dispatch } = this.props
    dispatch(updatePrivateFlag(accessToken.accessToken, !user.privateFlag))
  }
  render() {
    const { user } = this.props
    let checked = user.privateFlag === true ? "checked" : ""
    return (
      <div className="page-settings-privacy">
        <h1 className="heading">プライバシーの設定</h1>
        <div className="checkbox">
          <input type="checkbox" checked={checked} id="privacy" onChange={() => this.updateChceckbox()} />
          <label for="privacy">ランキングへの参加</label>
        </div>
        <p className="description">OFFにすると、翌日からランキングに表示されなくなります。</p>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    user: state.user
  }
}

export default connect(mapStateToProps)(SettingsPrivacy)