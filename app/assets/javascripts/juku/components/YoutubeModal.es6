import React, { Component } from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

export class YoutubeModal extends Component {

  constructor(props) {
    super(props)
  }

  closeModal(e) {
    this.props.onClose()
  }

  render() {
    const { isActive, youtubeURL } = this.props
    let modalClass = classNames('Modal', {active: isActive})
    let modalContainerClass = classNames('Modal__container', {active: isActive})
    return (
      <div className={modalClass}>
        <div className={modalContainerClass}>
          <button className="Modal__close" onClick={(e) => this.closeModal()} />
          <h2 className="Modal__title">映像授業</h2>
          <div className="Modal__contents">
            {(() => {
              if(this.props.isActive){
                return <iframe width="503" height="283" src={youtubeURL} frameborder="0" allowfullscreen></iframe>
              }
            })()}
          </div>
        </div>
      </div>
    )
  }
}

YoutubeModal.propTypes = {
  isActive: PropTypes.bool.isRequired
}
export default YoutubeModal