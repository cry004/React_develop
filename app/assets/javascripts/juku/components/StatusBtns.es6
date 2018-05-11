import React, { Component } from 'react'

export class StatusBtns extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { learning_status, editFlag } = this.props

    //印刷のbackground-imageが効かないのでここだけimageタグを使う
    const imageOk = document.getElementById("imageOk");
    const imageNg = document.getElementById("imageNg");
    const imageOkOn = document.getElementById("imageOkOn");
    const imageNgOn = document.getElementById("imageNgOn");

    let iconReviewClass
    let iconPassClass
    let printIconReviewClass
    let printIconPassClass
    let printRevieImage
    let printPassImage
    switch(learning_status) {
      case 'pass':
        iconReviewClass = 'icon-review-off is-pc'
        printIconReviewClass = 'icon-review-off is-print'
        printRevieImage = imageNg.getAttribute("data-url")
        iconPassClass = 'icon-pass-on is-pc'
        printIconPassClass = 'icon-pass-on is-print'
        printPassImage = imageOkOn.getAttribute("data-url")
        break;
      case 'failure':
        iconReviewClass = 'icon-review-on is-pc'
        printIconReviewClass = 'icon-review-on is-print'
        printRevieImage = imageNgOn.getAttribute("data-url")
        iconPassClass = 'icon-pass-off is-pc'
        printIconPassClass = 'icon-pass-off is-print'
        printPassImage = imageOk.getAttribute("data-url")
        break;
      default:
        iconReviewClass = 'icon-review-off is-pc'
        printIconReviewClass = 'icon-review-off is-print'
        printRevieImage = imageNg.getAttribute("data-url")
        iconPassClass = 'icon-pass-off is-pc'
        printIconPassClass = 'icon-pass-off is-print'
        printPassImage = imageOk.getAttribute("data-url")
        break;
    }
    return (
      <ul className="btns">
        <li>
          <i className={iconReviewClass} />
          <p className={printIconReviewClass}>
            <img src={printRevieImage} width='41' />
          </p>
        </li>
        <li>
          <i className={iconPassClass} />
          <p className={printIconPassClass}>
            <img src={printPassImage} width='41' />
          </p>
        </li>
      </ul>
    )
  }
}