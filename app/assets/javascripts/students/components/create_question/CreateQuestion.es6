import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

import { Subjects } from './subjects/Subjects.es6'
import { Photo } from './photo/Photo.es6'
import { Question } from './question/Question.es6'

import { showPopup } from '../../actions/popup.es6'
import { updateQuestion,
  updateQuestionByVideo,
  updateImage,
  updatePreview,
  requestQuestionDraft,
  initCreateQuestion,
  initImageFile,
  createQuestionErrorMessage,
  selectSubject } from '../../actions/createQuestion.es6'
import { requestUser } from '../../actions/user.es6'
import { postPlayTime,
  updatePlayTime,
  updateCurrentTime,
  updatePlayStartTime } from '../../actions/video.es6'

class CreateQuestion extends Component {

  constructor(props) {
    super(props)
    this.sendVideoPlayTime = this.sendVideoPlayTime.bind(this)
  }
  componentWillMount() {
    const { accessToken, createQuestion, dispatch } = this.props
    dispatch(createQuestionErrorMessage([]))
    dispatch(requestUser(accessToken.accessToken))
    if (createQuestion.status ===  "initial") {
      dispatch(initCreateQuestion())
    }
    if (createQuestion.status ===  "draft") {
      dispatch(initImageFile())
      dispatch(requestQuestionDraft(accessToken.accessToken, createQuestion.questionId))
    }
  }
  componentWillReceiveProps(nextProps) {
    const { createQuestion, dispatch } = this.props
    if (createQuestion.questionId !== nextProps.createQuestion.questionId) {
      if (createQuestion.status ===  "draft") {
        dispatch(requestQuestionDraft(accessToken.accessToken, createQuestion.questionId))
      }
    }
    if (createQuestion.imageFile === null && nextProps.createQuestion.imageFile !== null
      || createQuestion.text === "" && nextProps.createQuestion.text !== ""
      || !createQuestion.selectedSubject && !!nextProps.createQuestion.selectedSubject) {
      dispatch(createQuestionErrorMessage([]))
    }
  }
  componentDidMount() {
    window.addEventListener('hashchange', this.sendVideoPlayTime)
  }

  sendVideoPlayTime() {
    const { createQuestion } = this.props
    if (location.hash !== "#/video" && createQuestion.questionType === "video") {
      this.sendPlayTime()
    }
    window.removeEventListener('hashchange', this.sendVideoPlayTime)
  }
  showPopup(e) {
    const { user, dispatch } = this.props
    e.stopPropagation()
    dispatch(showPopup('requestpoint', {
      isNewUser: user.isNewUser
    }))
  }
  draftQuestion(e) {
    const { createQuestion, accessToken, dispatch } = this.props
    e.preventDefault()
    if (createQuestion.isSending === true) {
      return false
    }
    if (createQuestion.questionType === "video") {
      dispatch(updateQuestionByVideo(accessToken.accessToken, createQuestion.questionId, false, {body: createQuestion.text}))
      if (createQuestion.status === 'initial') {
        ga('send', 'event', '下書き保存する', 'click', 'pc_question_eizojugyo_draft', 1)
      }
    } else {
      dispatch(updateQuestion(accessToken.accessToken, createQuestion.questionId, false, {
        upload_file: createQuestion.imageFile,
        body: createQuestion.text,
        course_name: createQuestion.selectedSubject
      }))
      if (createQuestion.status === 'initial') {
        ga('send', 'event', '下書き保存する', 'click', 'pc_question_free_draft', 1)
      }
    }
  }
  submitQuestion(e) {
    const { user, createQuestion, accessToken, dispatch } = this.props
    e.preventDefault()
    if (createQuestion.isSending === true) {
      return false
    }
    if (createQuestion.questionType === "video") {
      dispatch(updateQuestionByVideo(accessToken.accessToken, createQuestion.questionId, true, {body: createQuestion.text}))
    } else {
      dispatch(updateQuestion(accessToken.accessToken, createQuestion.questionId, true, {
        upload_file: createQuestion.imageFile,
        body: createQuestion.text,
        course_name: createQuestion.selectedSubject
      }))
    }
  }
  updateFile(e) {
    const { dispatch } = this.props
    let fr = new FileReader()
    fr.readAsDataURL(e.target.files[0])
    dispatch(updateImage(e.target.files[0]))
    fr.onload = () => {
      dispatch(updatePreview(fr.result))
    }
  }
  sendPlayTime() {
    const { video, accessToken, useragent, dispatch } = this.props
    const totalPlayTime = video.playTime
    if (totalPlayTime > 0) {
      dispatch(postPlayTime(accessToken.accessToken, video.id, parseInt(totalPlayTime + 1, 10)))
    }
    dispatch(updatePlayTime(0))
    dispatch(updateCurrentTime(0))
    dispatch(updatePlayStartTime(0))
  }

  render() {
    const { accessToken, user, createQuestion, dispatch } = this.props
    const isChecked = (i) => {
      return createQuestion.selectedSubject === i ? "checked" : ""
    }
    const isVideo = createQuestion.questionType === "video" ? true : false
    const submitButtonText = createQuestion.errorMessage.length > 0 ? createQuestion.errorMessage[0] : 'この内容で質問する'
    const submitButtonClass = classNames('el-button u-left', {
      'is-red': createQuestion.errorMessage.length > 0,
      'is-blue': createQuestion.errorMessage.length < 1
    })
    return (
      <div className="page-create-question">
        <div className="point">
          <div className="point-inner u-clearfix">
            <div className="u-left u-clearfix">
              <div className="point-inner-teacher u-left">
              </div>
              <p className="point-inner-balloon u-left">
                添削指導サービスのご利用には
                <br/>
                <span>{user.questionPoint}pt </span>必要です。
              </p>
            </div>
            <div className="u-right">
              <p className="point-inner-current">現在の所持ポイント<span>{user.availablePoint}</span>pt</p>
              <a className="point-inner-howto" onClick={(e) => this.showPopup(e)}>ポイントを増やすには？</a>
            </div>
          </div>
        </div>
        <div className="container">
          {(() => {
            if (isVideo === false) {
              return (
                <Subjects accessToken={accessToken} createQuestion={createQuestion} isChecked={isChecked} dispatch={dispatch} />
              )
            }
          })()}
          <div className="u-clearfix">
            <Photo updateFile={this.updateFile.bind(this)} createQuestion={createQuestion} isVideo={isVideo} dispatch={dispatch} />
            <Question createQuestion={createQuestion} isVideo={isVideo} dispatch={dispatch} />
          </div>
          <div className="container-button">
            <form className="button">
              <button type="submit" className="el-button u-left is-white" onClick={(e) => this.draftQuestion(e)}>下書き保存する</button>
            </form>
            <form className="button">
              <button onClick={(e) => this.submitQuestion(e)} className={submitButtonClass}>{submitButtonText}</button>
            </form>
          </div>
        </div>
      </div>
    )
  }
}
const mapStateToProps = (state) => {
  return {
    accessToken: state.accessToken,
    createQuestion: state.createQuestion,
    user: state.user,
    video: state.video,
    useragent: state.useragent,
    locationHash: state.locationHash
  }
}

export default connect(mapStateToProps)(CreateQuestion);