import React, { Component } from 'react'
import { connect } from 'react-redux'
import moment from 'moment'

import { requestHistories,
  setHistoryCalActive,
  changeHistoryStartDate,
  changeHistoryEndDate,
  changeHistorySubjectID,
  changeHistoryStatus,
  initIsFetchedHistories } from '../actions/History.es6'
import { setYoutubeURL,
  setYoutubeModal } from '../actions/Curriculums.es6'
import { changeSeletedBoxID, changeSelectedAgreementID } from '../actions/Boxes.es6'
import { changeReportedAt } from '../actions/Reports.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'
import { Breadcrumbs } from '../components/Breadcrumbs.es6'
import { CurriculumDates } from '../components/CurriculumDates.es6'
import { YoutubeModal } from '../components/YoutubeModal.es6'
import { HistoryItem } from '../components/StudentHistoryItem.es6'
import { Loading } from '../components/Loading.es6'

export class StudentHistory extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {
    const initSubject = null
    const { dispatch, access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, historyStatus, isFetchedHistories } = this.props
    dispatch(requestHistories(access_token, selected_student_id, historyStartDate, historyEndDate, initSubject, historyStatus))
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(changeHistorySubjectID(null))
    dispatch(initIsFetchedHistories())
    this.closeYoutubeModal()
    dispatch(changeHistoryStartDate(moment().subtract(3, 'months').format('YYYY-MM-DD')))
    dispatch(changeHistoryEndDate(moment().format('YYYY-MM-DD')))
    dispatch(initErrorMessage())
  }

  onSetCalStartActive(isHistoryCalStartActive) {
    const { dispatch, isHistoryCalEndActive } = this.props
    dispatch(setHistoryCalActive(isHistoryCalStartActive, isHistoryCalEndActive))
  }

  onSetCalEndActive(isHistoryCalEndActive) {
    const { dispatch, isHistoryCalStartActive } = this.props
    dispatch(setHistoryCalActive(isHistoryCalStartActive, isHistoryCalEndActive))
  }

  hideCalAndChangeStartDate(start_date) {
    const { dispatch, access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, historyStatus } = this.props
    if(historyEndDate > start_date || historyEndDate == ''){
      dispatch(changeHistoryStartDate(moment(start_date).format('YYYY-MM-DD')))
      dispatch(requestHistories(access_token, selected_student_id, start_date, historyEndDate, historySubjectID, historyStatus))
    }
  }

  hideCalAndChangeEndDate(end_date) {
    const { dispatch, access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, historyStatus } = this.props
    if(historyStartDate < end_date || historyStartDate == ''){
      dispatch(changeHistoryEndDate(moment(end_date).format('YYYY-MM-DD')))
      dispatch(requestHistories(access_token, selected_student_id, historyStartDate, end_date, historySubjectID, historyStatus))
    }
  }

  onChangeSubject(subject) {
    const { dispatch, access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, historyStatus } = this.props
    dispatch(changeHistorySubjectID(subject))
    dispatch(requestHistories(access_token, selected_student_id, historyStartDate, historyEndDate, subject, historyStatus))
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

  onClickStatusBtn(status) {
    const { dispatch, access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, historyStatus } = this.props
    dispatch(changeHistoryStatus(status))
    dispatch(requestHistories(access_token, selected_student_id, historyStartDate, historyEndDate, historySubjectID, status))
  }

  returnStatusBtns(historyStatus) {
    let dom
    switch(historyStatus) {
      case null:
      case "scheduled":
      case "sent":
      default:
        dom = <ul className="btns"><li><i className="icon-all-on" /></li><li><a className="icon-review-off" onClick={this.onClickStatusBtn.bind(this, 'failure')} /></li><li><a className="icon-pass-off" onClick={this.onClickStatusBtn.bind(this, 'pass')} /></li></ul>
        break;
      case 'failure':
        dom = <ul className="btns"><li><a className="icon-all-off" onClick={this.onClickStatusBtn.bind(this, null)} /></li><li><i className="icon-review-on" /></li><li><a className="icon-pass-off" onClick={this.onClickStatusBtn.bind(this, 'pass')} /></li></ul>
        break;
      case 'pass':
        dom = <ul className="btns"><li><a className="icon-all-off" onClick={this.onClickStatusBtn.bind(this, null)} /></li><li><a className="icon-review-off" onClick={this.onClickStatusBtn.bind(this, 'failure')} /></li><li><i className="icon-pass-on" /></li></ul>
        break;
    }
    return dom
  }

  onMoveReport(box_id, agreement_id, reported_at) {
    const { dispatch, selected_agreement_id } = this.props
    dispatch(changeSelectedAgreementID(agreement_id))
    dispatch(changeSeletedBoxID(box_id))
    dispatch(changeReportedAt(reported_at))
    window.location.hash = '/report'
  }

  render() {
    const { student, historyStatus, prefectures, onChange, value, historyLearnings, historySubjects, selected_student_name, isHistoryCalStartActive, isHistoryCalEndActive, historyStartDate, historyEndDate, checkedSubUnits, selected_agreement_id, isFetchedHistories } = this.props
    return(
      <div className="StudentHistory">
        <Breadcrumbs items={this.props.breadcrumbs} />
        <div className="Curriculums__header">
          <div className="Curriculums__header-left">
            <p className="avatar"><img src={student.avatar_url} width='49' /></p>
            <div className="info-1">
              <p className="name">{selected_student_name}さん</p>
            </div>
          </div>
        </div>
        <div className="StudentHistory__header">
          <div className="StudentHistory__header-left">
            <div className="date">
              <CurriculumDates
              this_date={moment(historyStartDate).format('YYYY/MM/DD')}
              isCalActive={isHistoryCalStartActive}
              onSetEditCalActive={this.onSetCalStartActive.bind(this)}
              onCalChange={this.hideCalAndChangeStartDate.bind(this)} />
              <span className="calender-label">〜</span>
              <CurriculumDates
              this_date={moment(historyEndDate).format('YYYY/MM/DD')}
              isCalActive={isHistoryCalEndActive}
              onSetEditCalActive={this.onSetCalEndActive.bind(this)}
              onCalChange={this.hideCalAndChangeEndDate.bind(this)} />
            </div>
            <div className="subject">
              <select className="arrow-r small" onChange={(e) => this.onChangeSubject(e.target.value)}>
                <option value='null'>全教科</option>
                {historySubjects.map(subject =>
                  <option value={subject.subject_id} key={subject.subject_id}>{subject.subject_name}</option>
                  )}
                }
              </select>
            </div>
          </div>
          <div className="StudentHistory__header-right">
            <div className="status">
              <span className="btns-label">理解度で絞り込む：</span>
              {this.returnStatusBtns(historyStatus)}
            </div>
          </div>
        </div>
        <Loading isFetched={isFetchedHistories} />
        <div className="StudentHistory__container">
          {(() => {
            if(historyLearnings.length < 1){
              return <div className="nodata">表示可能なデータがありません。</div>
            }
          })()}
          {historyLearnings.map((learning, learningIndex) => {
            return <div key={'learning' + learningIndex}>
              <div className="StudentHistory__date">
                <p className="dates">授業実施日：<span className="date">{moment(learning.date).format('YYYY/MM/DD（ddd）')} {learning.period_start_time}〜{learning.period_end_time}</span><br />
                報告書作成日時：<span className="date report">{moment(learning.reported_at).format('YYYY/MM/DD（ddd） HH:mm:ss')}</span></p>
                <a className="link" onClick={this.onMoveReport.bind(this, learning.box_id, learning.agreement_id, learning.reported_at)}>日次学習報告書を見る</a>
              </div>
              <div className="Curriculums-container">
                <div className="Curriculums-detail">
                  {learning.items.map((item, itemIndex) => {
                    return <div className="curriculum" key={'item' + itemIndex}>
                      <div className="curriculum-subject">
                        <h2 className="subject">{item.sub_subject_name}</h2>
                      </div>
                      <div className="curriculum-title">
                        <h2 className="title">{item.unit_name}</h2>
                      </div>
                      <HistoryItem
                      item={item}
                      entrance_exam_flag={learning.entrance_exam_flag}
                      openYoutubeModal={this.openYoutubeModal}
                      setYoutubeURL={this.setYoutubeURL.bind(this)} />
                    </div>
                  })}
                </div>
              </div>
            </div>
          })}
        </div>
        <YoutubeModal isActive={this.props.isYoutubeModal} onClose={this.closeYoutubeModal.bind(this)} youtubeURL={this.props.youtubeURL} />
      </div>
    )
  }

}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "生徒詳細", url: "/student"}, {label: "学習履歴"}],
    access_token: state.requestAccessToken.access_token,
    student: state.requestCurriculums.student,
    selected_student_id: state.requestBoxes.selected_student_id,
    historyLearnings: state.requestHistories.historyLearnings,
    historySubjects: state.requestHistories.historySubjects,
    selected_student_name: state.requestBoxes.selected_student_name,
    historyStartDate: state.requestHistories.historyStartDate,
    historyEndDate: state.requestHistories.historyEndDate,
    isHistoryCalStartActive: state.requestHistories.isHistoryCalStartActive,
    isHistoryCalEndActive: state.requestHistories.isHistoryCalEndActive,
    checkedSubUnits: state.requestCurriculums.checkedSubUnits,
    historyStatus: state.requestHistories.historyStatus,
    historySubjectID: state.requestHistories.historySubjectID,
    agreement: state.requestCurriculums.agreement,
    selected_agreement_id: state.requestBoxes.selected_agreement_id,
    selected_box_id: state.requestBoxes.selected_box_id,
    isYoutubeModal: state.requestCurriculums.isYoutubeModal,
    youtubeURL: state.requestCurriculums.youtubeURL,
    isFetchedHistories: state.requestHistories.isFetchedHistories
  }
}

export default connect(mapStateToProps)(StudentHistory);
