import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { connect } from 'react-redux'
import moment from 'moment'
import classNames from 'classnames'

import { putLearning, changeSubSubject, requestCurriculums, setSettingModal, setYoutubeURL, setYoutubeModal, setPdfModal, initIsFetchedCurriculums } from '../actions/Curriculums.es6'
import { requestLearnings, changeSetLearnings, changePdfListBtnDisable, initIsFetchedLearnings } from '../actions/Learnings.es6'
import { postLearningReport, initisReadyToPrint } from '../actions/Reports.es6'
import { setDefaultPdf, joinPdfs } from '../actions/Pdf.es6'
import { PrintModal } from '../components/PrintModal.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'
import { Breadcrumbs } from '../components/Breadcrumbs.es6'
import { YoutubeModal } from '../components/YoutubeModal.es6'
import { CurriculumsInfo } from '../components/CurriculumsInfo.es6'
import { Curriculums } from '../components/Curriculums.es6'
import { CurriculumsPrintBtns } from '../components/CurriculumsPrintBtns.es6'
import { Loading } from '../components/Loading.es6'

export class StudentDetail extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {

    const { dispatch, curriculums, access_token, selected_student_id,
      selected_sub_subject_key,
      selected_box_id,
      selected_agreement_id,
      selected_subject_id } = this.props

    dispatch(requestCurriculums(curriculums,
      access_token,
      selected_student_id,
      selected_box_id,
      selected_agreement_id,
      selected_sub_subject_key,
      selected_subject_id))
    dispatch(initisReadyToPrint())
    let student_id = this.props.selected_student_id
    let status = 'sent'

    dispatch(requestLearnings(access_token, student_id, selected_box_id, null, status))
    dispatch(setSettingModal(true))
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(initIsFetchedCurriculums())
    dispatch(initIsFetchedLearnings())
    this.closeYoutubeModal()
    dispatch(initErrorMessage())
  }
  componentDidMount() {
    window.scrollTo(0, 0)
  }

  onSetCurriculums(sub_subject_key, sub_subject_name) {
    const { dispatch, curriculums, access_token, selected_student_id,
      selected_box_id,
      selected_agreement_id,
      selected_subject_id } = this.props
    dispatch(initIsFetchedCurriculums())
    dispatch(requestCurriculums(curriculums,
      access_token,
      selected_student_id,
      selected_box_id,
      selected_agreement_id,
      sub_subject_key,
      selected_subject_id))

    dispatch(changeSubSubject(sub_subject_key, sub_subject_name))
  }

  openYoutubeModal() {
    const { dispatch } = this.props
    dispatch(setYoutubeModal(true))
  }

  setYoutubeURL(newYoutubeURL) {
    const { dispatch } = this.props
    dispatch(setYoutubeURL(newYoutubeURL))
    this.openYoutubeModal()
  }

  closeYoutubeModal() {
    const { dispatch } = this.props
    dispatch(setYoutubeModal(false))
  }

  // いらない引数消すsent_on
  onSetLearning(learning_id, box_id, status, sent_on, student_id, period_id, sub_unit_id) {
    const { dispatch, setLearnings, access_token, selected_box_id, selected_date, learnings, selected_agreement_id, selected_student_id } = this.props
    dispatch(putLearning(learnings, setLearnings, access_token, learning_id, selected_box_id, status, selected_date, student_id, period_id, sub_unit_id, selected_agreement_id))
    dispatch(setSettingModal(true))
  }

  onPostLearningReport() {
    const { dispatch, access_token, box_id, isReadyToPrint, selected_agreement_id, student } = this.props
    let reported_at = moment().format('YYYY-MM-DD HH:mm:ss')
    let student_id = student.student_id

    if( !isReadyToPrint ){
      dispatch(postLearningReport(access_token, box_id, reported_at, selected_agreement_id, student_id))
    }
    this.onChangePdfListDisable(true)
  }

  onSetLearningStatus(setLearnings, learning_id, status) {
    const { dispatch } = this.props
    dispatch(changeSetLearnings(setLearnings, learning_id, status))
  }

  onChangePdfListDisable(pdfListBtnDisable) {
    const { dispatch } = this.props
    dispatch(changePdfListBtnDisable(pdfListBtnDisable))
  }

  closePrintModal() {
    this.onSetPdfModal(false)
    const { dispatch } = this.props
    dispatch(setDefaultPdf())
  }

  onSetPdfModal(pdfModalFlag) {
    const { dispatch, access_token, curriculum, selected_student_id, selected_box_id, selected_subject_id } = this.props
    dispatch(setPdfModal(pdfModalFlag))

    let student_id = this.props.selected_student_id
    let subject_id = this.props.selected_subject_id
    let status = 'sent'
    let start_date = curriculum.start_date
    let end_date = curriculum.end_date
  }

  getPdfLink(pdfLinks) {
    const { dispatch } = this.props
    const envName = document.querySelector('body').getAttribute('data-env-name')
    dispatch(joinPdfs(pdfLinks, envName))
  }

  returnSubSubjectClass(key) {
    const { selected_sub_subject_key } = this.props
    let selected_key
    selected_key = selected_sub_subject_key
    let subsubjectClass = classNames({"active": (key == selected_key)})
    return subsubjectClass
  }

  onSetDefaultPdf(){
    const { dispatch } = this.props
    dispatch(setDefaultPdf())
  }

  render() {
    const { errorMessage, joinedPdfResponceStatus, isJoinedPdfStatus, checkedSubUnits, agreement, setLearnings, sub_subjects, curriculum, learnings, student,
    selected_sub_subject_name, joinedPdfUrl, dispatch, isFetchedCurriculums, isFetchedLearnings } = this.props

    let total_video_duration = 0

    if(learnings.units) {
      learnings.units.map(unit => {
        unit.sub_units.map(sub_unit => {
          if(sub_unit.learning_status == 'sent' && sub_unit.box_id == +this.props.box_id) {
            total_video_duration += sub_unit.total_duration
          }
        })
      })
    }

    let total_video_duration_min = Math.floor(total_video_duration / 60)
    let subjectStyle = { color: agreement.subject_color_code}

    return (
      <div className="StudentDetail">
        <Breadcrumbs items={this.props.breadcrumbs} />
        <Loading isFetched={isFetchedLearnings&&isFetchedCurriculums} />
        <div className="Curriculums__container">
          <div className="Curriculums__header">
            <div className="Curriculums__header-left">
              <p className="avatar"><img src={student.avatar_url} width='49' /></p>
              <div className="info-1">
                <p className="name">{student.student_name}さん</p>
                <p className="grade">{student.schoolyear}</p>
                <Link className="history" to="/history">この生徒の学習履歴を見る</Link>
              </div>
              <div className="info-2">
                <p className="date">{agreement.agreement_dow_name} {agreement.start_time}~{agreement.end_time}</p>
                <p className="subject" style={subjectStyle}>{agreement.subject_name}</p>
              </div>
            </div>
            <CurriculumsPrintBtns
            onSetPdfModal={this.onSetPdfModal.bind(this)}
            onPostLearningReport={this.onPostLearningReport.bind(this)}
            learnings={learnings}
            box_id={+this.props.box_id}
             />
          </div>
          <CurriculumsInfo selected_sub_subject_name={selected_sub_subject_name} learnings={learnings} curriculum={curriculum} agreement={agreement} dispatch={dispatch} isActive={this.props.isResetModal} />
          <div className="Curriculums-container">
            <div className="Curriculums-menu">
              <ul>
                {sub_subjects.map(sub_subject =>
                  <li key={sub_subject.sub_subject_key}>
                    <a onClick={(e) => this.onSetCurriculums(sub_subject.sub_subject_key, sub_subject.sub_subject_name)} className={this.returnSubSubjectClass(sub_subject.sub_subject_key)} data-key={sub_subject.sub_subject_key}>{sub_subject.sub_subject_name}</a>
                  </li>
                )}
              </ul>
            </div>
            <div className="Curriculums-detail">
              <div className="time_movie-container">
                <p className="title">
                  <span className="pink">設定した授業時間の合計</span><br />
                    {(() => {
                      if (learnings.entrance_exam_flag !== false) {
                        return <span>※入試対策編は２本選択してください。</span>
                      }
                    })()}
                </p>
                <p className="time_movie">{total_video_duration_min}分</p>
              </div>
              <div className="legend">
                <p><i className="icon-process-off-scheduled" />カリキュラム設定済</p>
              </div>
              <Curriculums onSetLearning={this.onSetLearning.bind(this)}
              learnings={learnings}
              setLearnings={setLearnings}
              onSetLearningStatus={this.onSetLearningStatus.bind(this)}
              openYoutubeModal={this.openYoutubeModal}
              setYoutubeURL={this.setYoutubeURL.bind(this)}
              editFlag={false}
              checkedSubUnits={checkedSubUnits}
              student_id={this.props.selected_student_id}
              period_id={this.props.selected_period_id}
              box_id={+this.props.box_id} />
            </div>
          </div>
        </div>
        <YoutubeModal isActive={this.props.isYoutubeModal} onClose={this.closeYoutubeModal.bind(this)} youtubeURL={this.props.youtubeURL} />
        <PrintModal errorMessage={errorMessage} isHaveReport={false} joinedPdfResponceStatus={joinedPdfResponceStatus} joinedPdfUrl={joinedPdfUrl} isJoinedPdfStatus={isJoinedPdfStatus} setLearnings={setLearnings} isActive={this.props.isPdfModal} onClose={this.closePrintModal.bind(this)} onGetPdfLink={this.getPdfLink.bind(this)} />
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "生徒詳細"}],
    access_token: state.requestAccessToken.access_token,
    box_id: state.requestCurriculums.box_id,
    student: state.requestCurriculums.student,
    agreement: state.requestCurriculums.agreement,
    sub_subjects: state.requestCurriculums.sub_subjects,
    subject_names: state.requestCurriculums.subject_names,
    curriculum: state.requestCurriculums.curriculum,
    learnings: state.requestCurriculums.learnings,
    isYoutubeModal: state.requestCurriculums.isYoutubeModal,
    isPdfModal: state.requestCurriculums.isPdfModal,
    isResetModal: state.requestCurriculums.isResetModal,
    selected_sub_subject_key: state.requestCurriculums.selected_sub_subject_key,
    selected_sub_subject_name: state.requestCurriculums.selected_sub_subject_name,
    selected_student_id: state.requestBoxes.selected_student_id,
    selected_period_id: state.requestBoxes.selected_period_id,
    selected_box_id: state.requestBoxes.selected_box_id,
    selected_date: state.requestBoxes.selected_date,
    selected_subject_id: state.requestBoxes.selected_subject_id,
    selected_schoolyear_key: state.requestBoxes.selected_schoolyear_key,
    selected_agreement_id: state.requestBoxes.selected_agreement_id,
    youtubeURL: state.requestCurriculums.youtubeURL,
    setLearnings: state.requestLearnings.setLearnings,
    pdfListBtnDisable: state.requestLearnings.pdfListBtnDisable,
    checkedSubUnits: state.requestCurriculums.checkedSubUnits,
    joinedPdfUrl: state.requestPdf.joinedPdfUrl,
    isJoinedPdfStatus: state.requestPdf.isJoinedPdfStatus,
    joinedPdfResponceStatus: state.requestPdf.joinedPdfResponceStatus,
    errorMessage: state.requestPdf.errorMessage,
    isFetchedCurriculums: state.requestCurriculums.isFetchedCurriculums,
    isFetchedLearnings: state.requestLearnings.isFetchedLearnings,
    isReadyToPrint: state.requestLearningReports.isReadyToPrint
  }
}

export default connect(mapStateToProps)(StudentDetail);
