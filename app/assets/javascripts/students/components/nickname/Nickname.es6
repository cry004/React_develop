import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import constants from '../../constants.es6'
import { updateNickname,
  updateNicknameError } from '../../actions/user.es6'

class Nickname extends Component {
  constructor(props) {
    super(props)
    this.state = {
      _nickName: ""
    }
  }
  componentWillMount() {
    const { dispatch } = this.props
    dispatch(updateNicknameError([]))
  }

  submitName(e) {
    e.preventDefault(e)
    const nickNameLength = this.state._nickName.length
    if (nickNameLength < constants.nickNameLength.min || nickNameLength > constants.nickNameLength.max) {
      return false
    }
    const { accessToken, user, dispatch } = this.props
    dispatch(updateNickname(accessToken.accessToken, this.state._nickName, user.avatar, '/nickname'))
  }
  handleChange(e) {
    if (e.target.value.length > constants.nickNameLength.max) {
      return false
    }
    const { user, dispatch } = this.props
    this.setState({
      _nickName: e.target.value
    })
    if (user.nickNameError.length > 0) {
      dispatch(updateNicknameError([]))
    }
  }
  render() {
    const { user } = this.props
    const nickNameLength = this.state._nickName.length
    const nameMinLength = constants.nickNameLength.min
    const buttonText = user.nickNameError.length > 0 ? user.nickNameError[0] : '決定する'
    const buttonClass = classNames('el-button', {
      'is-red': user.nickNameError.length > 0,
      'is-blue': user.nickNameError.length < 1 && nickNameLength >= nameMinLength,
      'is-disabled': nickNameLength < nameMinLength
    })

    return (
      <div className="page-nickname">
        <form>
          <h2 className="el-heading">ニックネームを入力</h2>
          <div className="el-textbox has-icon is-man">
            <input type="text" placeholder="ニックネームを入力" value={this.state._nickName} onChange={(e) => this.handleChange(e)} />
          </div>
          <p className="annotation">
            2文字以上16文字以内で入力してください。
            <br/>
            ニックネームはランキングに表示されることがあります。
          </p>
          <button onClick={(e) => this.submitName(e)} className={buttonClass}>{buttonText}</button>
        </form>
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

export default connect(mapStateToProps)(Nickname);