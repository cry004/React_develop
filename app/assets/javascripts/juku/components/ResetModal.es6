import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import PropTypes from 'prop-types'
import classNames from 'classnames'

export class ResetModal extends Component {

  constructor(props) {
    super(props)
  }

  closeModal(e) {
    this.props.onClose()
  }

  render() {
    const { isActive } = this.props
    let modalClass = classNames('Modal', {active: isActive})
    let modalContainerClass = classNames('Modal__container', {active: isActive})
    return (
      <div className={modalClass}>
        <div className={modalContainerClass}>
          <button className="Modal__close" onClick={(e) => this.closeModal()} />
          <h2 className="Modal__title">カリキュラム再設定</h2>
          <div className="Modal__contents">
            <div className="resetcurriculum">
              <p>カリキュラムの再設定をすると</p>
              <p>現在設定しているカリキュラムは削除されますのでご注意ください。</p>
              <Link to="/edit" className="el-button" onClick={(e) => this.closeModal()}>OK</Link>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

ResetModal.propTypes = {
  isActive: PropTypes.bool.isRequired,
  onClose: PropTypes.func.isRequired
}


export default ResetModal

