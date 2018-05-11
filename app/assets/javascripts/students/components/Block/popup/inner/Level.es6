import React, { Component } from 'react'
import classNames from 'classnames'

export class Level extends Component {
  constructor(props) {
    super(props)
  }
  selectOk() {
    const { hidePopup, dispatch } = this.props
    // dispatch levelをfalseにする
    //if(trophy === true) {
    //  dispatch(showPopup('trophy'))
    //} else {
    //  hidePopup();  
    //} 
    hidePopup();
  }
  render() {
    const { user, args } = this.props
    const iconClass = `el-icon is-${parseInt(user.avatar, 10)}`
    return (
      <div className="level">
        <p className="level-heading">レベルアップ！</p>
        <div className="level-image">
          <div className={iconClass}></div>
        </div>
        <p className="level-text">
          <span className="level-text-level">Lv </span>
          <span className="level-text-number">{args.level}</span>
          <br/>
          にアップしました。
        </p>
        <a className="el-button is-blue size-small" onClick={() => this.selectOk()}>OK</a>
      </div>
    )
  }
}