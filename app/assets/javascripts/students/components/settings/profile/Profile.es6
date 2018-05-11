import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import constants from '../../../constants.es6'
import { MyStatus } from '../../Block/my_status/MyStatus.es6'
import { updateNickname,
  updateNicknameSuccess,
  updateNicknameError,
  requestUser } from '../../../actions/user.es6'
import { requestLearningProgresses } from '../../../actions/learningProgresses.es6'


class SettingsProfile extends Component {
  constructor(props) {
    super(props)

    const { user } = this.props
    this.state = {
      _nickName: user.nickName
    }
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestUser(accessToken.accessToken))
    dispatch(updateNicknameSuccess(""))
    dispatch(updateNicknameError([]))
    dispatch(requestLearningProgresses(accessToken.accessToken))
  }

  submitNickName(e) {
    e.preventDefault()
    const nickNameLength = this.state._nickName.length
    if (nickNameLength < constants.nickNameLength.min || nickNameLength > constants.nickNameLength.max) {
      return false
    }
    const { accessToken, user, dispatch } = this.props
    dispatch(updateNickname(accessToken.accessToken, this.state._nickName , user.avatar, '/setting_profile'))
  }
  changeText(e) {
    if (e.target.value.length > constants.nickNameLength.max) {
      return false
    }
    const { dispatch } = this.props
    this.setState({_nickName: e.target.value})
    dispatch(updateNicknameSuccess(""))
    dispatch(updateNicknameError([]))
  }
  render() {
    const { user, location, learningProgresses } = this.props
    let buttonText = ""
    if (user.nickNameError.length > 0) {
      buttonText = user.nickNameError[0]
    } else if (user.nickNameSuccess !== "") {
      buttonText = user.nickNameSuccess
    } else {
      buttonText = "決定する"
    }
    const nickNameLength = this.state._nickName.length
    const nameMinLength = constants.nickNameLength.min
    const buttonClass = classNames('el-button', {
      'is-red': user.nickNameError.length > 0, 
      'is-blue': user.nickNameError.length < 1 && nickNameLength >= nameMinLength,
      'is-disabled': nickNameLength < nameMinLength
    })
    return (
      <form className="page-settings-profile">
        <MyStatus learningProgresses={learningProgresses} pathname="/settings_profile" nickName={this.state._nickName} changeText={this.changeText.bind(this)} />
        <p className="annotation">
          2文字以上16文字以内で入力してください。
          <br/>
          ニックネームはランキングに表示されることがあります。
        </p>
        <button className={buttonClass} onClick={(e) => this.submitNickName(e)}>{buttonText}</button>
      </form>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    user: state.user,
    accessToken: state.accessToken,
    learningProgresses: state.learningProgresses
  }
}

export default connect(mapStateToProps)(SettingsProfile);