import React, { Component } from 'react'

import { updateText,
  updatePreview } from '../../../actions/createQuestion.es6'

export class Photo extends Component {
  constructor(props) {
    super(props)
  }
  componentDidMount() {
    const { createQuestion, dispatch } = this.props
    if (createQuestion.questionType === 'other' 
      && createQuestion.status === 'draft'
      && !!createQuestion.resourceUrl) {
      dispatch(updatePreview(createQuestion.resourceUrl)) 
    } else {
      dispatch(updatePreview("")) 
    }
  }
  componentWillReceiveProps(nextProps) {
    const { createQuestion, dispatch } = this.props
    if (createQuestion.resourceUrl !== nextProps.createQuestion.resourceUrl) {
      if (nextProps.createQuestion.questionType === 'other') {
        if ( nextProps.createQuestion.status === 'draft' && !!nextProps.createQuestion.resourceUrl) {
          dispatch(updatePreview(nextProps.createQuestion.resourceUrl))
        } else {
          dispatch(updatePreview(""))
        }
      }
    }
  }

  render() {
    const { createQuestion, updateFile, isVideo, dispatch } = this.props
    return(
      <div className="u-left container-photo">
        <div className="container-heading">
          {(() => {
            if (isVideo === false) {
              return (
                <p className="heading">
                  ② 質問したい内容の写真を１枚アップロードしてください。
                </p>
              )
            } else {
              return (
                <div>
                  <p className="heading">
                    質問を入力してください。
                  </p>
                  <p className="description">
                    質問は先生に伝わるように詳しく書いてください。
                  </p>
                </div>
              )
            }
          })()}
        </div>
        {(() => {
          if (isVideo === false) {
            return (
              <div className="container-photo-input">
                <div className="container-photo-input-image"></div>
                <div className="container-photo-input-image-prev">
                  {(() => {
                    if (!!createQuestion.prevImageSrc) {
                      return (
                        <img src={createQuestion.prevImageSrc} />
                      )
                    }
                  })()}
                </div>
                <input className="container-photo-input-image-input" type="file" accept='.jpg,.png,image/jpeg,image/png' multiple="" onChange={(e) => updateFile(e)} ref={(file) => this.fileDom = file} ref={(file) => this.fileDom = file} />
              </div>
            )
          } else {
            return (
              <div className="container-photo-input">
                <div className="container-photo-input-image"></div>
                <div className="container-photo-input-image-prev">
                  <img src={createQuestion.resourceUrl} />
                </div>
              </div>
            )
          }
        })()}
      </div>
    )
  }
}





