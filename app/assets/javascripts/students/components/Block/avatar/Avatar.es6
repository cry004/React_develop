import React, { Component } from 'react'
import { connect } from 'react-redux'

import { updateAvatar } from '../../actions/user.es6'

class Avatar extends Component {
  constructor(props) {
    super(props)
    const { user } = this.props
    this.state = {
      _iconId: user.avatar || 0
    }
  }
  componentWillMount() {
    const { user } = this.props
    if (!user.nickName) {
      window.location.hash = '/nickname'
    }
  }

  selectIcon(iconId) {
    const { dispatch } = this.props
    this.setState({
      _iconId: iconId
    })
  }
  submitIcon() {
    const { accessToken, user, locationHash, dispatch } = this.props
    // /nickname　→ /avatar → /study_status または
    // /setting_profile → /avatar → /setting_proile の遷移
    const nextPath = locationHash.prev === '/nickname' ? '/learning_progresses' : '/settings_profile'
    dispatch(updateAvatar(accessToken.accessToken, user.nickName, this.state._iconId, nextPath))
  }
  render() {
    let rows = [];
    for (let i = 0; i < 20; i++) {
      let labelClass= `is-${i}`
      let iconId = `icon${i}`
      let checked = parseInt(this.state._iconId, 10) === i ? "checked" : ""
      rows.push(<div key={i} className="icon"><input type="radio" id={iconId} value={i} name="icon" onChange={() => this.selectIcon(i)} checked={checked} /><label className={labelClass} htmlFor={iconId}></label></div>);
    }
    return (
      <div className="page-avatar">
        <div>
          <h2 className="el-heading">アイコンの選択</h2>
          <div className="icons u-clearfix">
            {rows}
          </div>
          <a className="el-button is-blue" onClick={() => this.submitIcon()}>決定する</a>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    user: state.user,
    accessToken: state.accessToken,
    locationHash: state.locationHash
  }
}

export default connect(mapStateToProps)(Avatar);