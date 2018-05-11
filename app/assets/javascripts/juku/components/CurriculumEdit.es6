import React, { Component } from 'react'
import { connect } from 'react-redux'
import moment from 'moment'

import { setEditCalActive,
  setCheckedSubUnits,
  requestCurriculums,
  setYoutubeURL,
  setYoutubeModal,
  postCurriculums,
  putCurriculums,
  changeCurriculumStartDate,
  changeCurriculumEndDate,
  changeIsCalStartActive,
  changeIsCalEndActive } from '../actions/Curriculums.es6'
import { requestNumberOfWeeks } from '../actions/NumberOfWeeks.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'
import { Breadcrumbs } from '../components/Breadcrumbs.es6'
import { YoutubeModal } from '../components/YoutubeModal.es6'
import { Curriculums } from '../components/Curriculums.es6'
import { CurriculumDates } from '../components/CurriculumDates.es6'



export class CurriculumEdit extends Component {

  constructor(props) {
    super(props)
  }

  componentWillMount() {
    const { dispatch, curriculum, access_token, selected_student_id,
      selected_sub_subject_key,
      selected_box_id,
      selected_agreement_id,
      learnings,
      selected_subject_id } = this.props

    dispatch(requestCurriculums(curriculum,
      access_token,
      selected_student_id,
      selected_box_id,
      selected_agreement_id,
      selected_sub_subject_key,
      selected_subject_id))

    let newCheckedSubUnits = []


    learnings.units.map(unit => unit.sub_units.map((sub_unit) => {
      if(sub_unit.curriculum_flag) {
        newCheckedSubUnits.push(sub_unit.sub_unit_id)
      }
    }))

    dispatch(setCheckedSubUnits(newCheckedSubUnits))

    if(Object.keys(curriculum).length === 0) {
      this.hideCalAndChangeStartDate(moment().format('YYYY-MM-DD'))
      this.hideCalAndChangeEndDate(moment().add(3, 'months').format('YYYY-MM-DD'))
    } else {
      this.hideCalAndChangeStartDate(moment(curriculum.start_date).format('YYYY-MM-DD'))
      this.hideCalAndChangeEndDate(moment(curriculum.end_date).format('YYYY-MM-DD'))
    }
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    this.closeYoutubeModal()
    dispatch(initErrorMessage())
  }

  onSetLearning(learning_id, box_id, status, sent_on) {
    const { dispatch, access_token } = this.props
    dispatch(putLearning(access_token, learning_id, box_id, status, sent_on))
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

  changeCheckedUnit(unit_id, bool) {
    const { learnings, checkedSubUnits, dispatch, curriculum } = this.props
    let newCheckedSubUnits = checkedSubUnits.concat()
    let sub_units
    learnings.units.map((unit) => {
      if(unit.unit_id == unit_id) {
        sub_units = unit.sub_units
      }
    })
    sub_units.map((sub_unit) => {
      let index = newCheckedSubUnits.indexOf(sub_unit.sub_unit_id)
      if(bool) {
        if (index < 0) {
          newCheckedSubUnits.push(sub_unit.sub_unit_id)
        }
      } else {
        if (index > -1) {
          newCheckedSubUnits.splice(index, 1)
        }
      }
    })
    dispatch(setCheckedSubUnits(newCheckedSubUnits))
  }

  changeCheckedSubUnit(sub_unit_id, bool) {
    const { checkedSubUnits, dispatch } = this.props
    let newCheckedSubUnits = checkedSubUnits.concat()
    let index = newCheckedSubUnits.indexOf(sub_unit_id)
    if(bool) {
      if (index < 0) {
        newCheckedSubUnits.push(sub_unit_id)
        dispatch(setCheckedSubUnits(newCheckedSubUnits))
      }
    } else {
      if (index > -1) {
        newCheckedSubUnits.splice(index, 1)
        dispatch(setCheckedSubUnits(newCheckedSubUnits))
      }
    }
  }

  onPostCurriculums(){
    const { curriculum, checkedSubUnits,
      dispatch, agreement,
      student, access_token,
      curEditStartDate, curEditEndDate,
      selected_sub_subject_key } = this.props

    if(Object.keys(curriculum).length === 0 || curriculum == null) {
      //未設定
      dispatch(postCurriculums(access_token,
        student.student_id,
        agreement.agreement_id,
        agreement.agreement_dow,
        moment(curEditStartDate).format('YYYY-MM-DD'),
        moment(curEditEndDate).format('YYYY-MM-DD'),
        agreement.period_id,
        checkedSubUnits,
        selected_sub_subject_key))
    } else {
      dispatch(putCurriculums(access_token,
        curriculum.curriculum_id,
        moment(curEditStartDate).format('YYYY-MM-DD'),
        moment(curEditEndDate).format('YYYY-MM-DD'),
        checkedSubUnits))
    }
  }

  hideCalAndChangeStartDate(start_date) {
    const { access_token, dispatch, curEditEndDate } = this.props
    if(curEditEndDate > start_date || curEditEndDate == '') {
      dispatch(changeCurriculumStartDate(moment(start_date).format('YYYY-MM-DD')))
      dispatch(requestNumberOfWeeks(access_token, start_date, curEditEndDate))
      dispatch(changeIsCalStartActive(false))
    }
  }

  hideCalAndChangeEndDate(end_date) {
    const { access_token, dispatch, curEditStartDate } = this.props
    if(curEditStartDate < end_date || curEditStartDate == '') {
      dispatch(changeCurriculumEndDate(moment(end_date).format('YYYY-MM-DD')))
      dispatch(requestNumberOfWeeks(access_token, curEditStartDate, end_date))
      dispatch(changeIsCalEndActive(false))
    }
  }

  onSetCalStartActive(isCalStartActive) {
    const { dispatch, isCalEndActive } = this.props
    dispatch(setEditCalActive(isCalStartActive, isCalEndActive))
  }

  onSetCalEndActive(isCalEndActive) {
    const { dispatch, isCalStartActive } = this.props
    dispatch(setEditCalActive(isCalStartActive, isCalEndActive))
  }

  returnAverageCurriculumNum(checkedSubUnitsLength, numberOfWeeks) {
    let averageCurriculumNum = 0
    if(numberOfWeeks > 0) {
      averageCurriculumNum = Math.ceil(Math.ceil((Number(checkedSubUnitsLength) / Number(numberOfWeeks)) * 100) * 0.1) / 10
    }
    return averageCurriculumNum
  }
  render() {
    const { selected_sub_subject_name, numberOfWeeks, isCalStartActive, isCalEndActive, checkedSubUnits, agreement, learnings, student, curEditStartDate, curEditEndDate } = this.props

    let countDom
    countDom = <p className="selected-movie">選択本数：<span className="number">{checkedSubUnits.length}/</span>{learnings.learnings_count}本</p>

    return (
      <div className="CurriculumEdit">
        <Breadcrumbs items={this.props.breadcrumbs} />
        <div className="Curriculums__header">
          <div className="Curriculums__header-left">
            <p className="avatar">
              <img src={student.avatar_url} width='49' />
            </p>
            <div className="info-1">
              <p className="name">{student.student_name}さん</p>
              <p className="grade">{student.schoolyear}</p>
            </div>
            <div className="info-2">
              <p className="date">
                {agreement.agreement_dow_name} {agreement.start_time}~{agreement.end_time}
              </p>
              <p className="subject">{this.props.subject_name}</p>
            </div>
          </div>
          <div className="Curriculums__header-right">
            {(() => {
              if(checkedSubUnits.length){
                return <input type="button" className="el-button color-pink" value="決定" onClick={this.onPostCurriculums.bind(this)} />
              }else{
                return <input type="button" className="el-button color-pink color-disabled" value="決定" onClick={this.onPostCurriculums.bind(this)} disabled="true" />
              }
            })()}
          </div>
        </div>
        <div className="Curriculums-info">
          <div className="info-4">
            <p className="calender-label">カリキュラム開始日</p>
            <CurriculumDates
            this_date={moment(curEditStartDate).format('YYYY/MM/DD')}
            isCalActive={isCalStartActive}
            onSetEditCalActive={this.onSetCalStartActive.bind(this)}
            onCalChange={this.hideCalAndChangeStartDate.bind(this)} />
            <p className="calender-label">カリキュラム完了予定日</p>
            <CurriculumDates
            this_date={moment(curEditEndDate).format('YYYY/MM/DD')}
            isCalActive={isCalEndActive}
            onSetEditCalActive={this.onSetCalEndActive.bind(this)}
            onCalChange={this.hideCalAndChangeEndDate.bind(this)} />
          </div>
          <div className="info-5">
            {countDom}
          </div>
        </div>
        <div className="CurriculumEdit-notification">
          <div className="CurriculumEdit-notification-left">
            <h2 className="subject">{selected_sub_subject_name}</h2>
            <p className="note">※チェックしてカリキュラムの範囲を設定してください。</p>
          </div>
          <div className="CurriculumEdit-notification-right">
            <p className="average-movie">
              １週間に見る必要がある授業数：
              <span className="big">
                {this.returnAverageCurriculumNum(checkedSubUnits.length, numberOfWeeks)}
              </span>
              本
            </p>
          </div>
        </div>
        <div className="Curriculums-container">
          <div className="Curriculums-detail">
            <div className="curriculum">
              <Curriculums onSetLearning={this.onSetLearning.bind(this)}
              learnings={learnings}
              openYoutubeModal={this.openYoutubeModal}
              setYoutubeURL={this.setYoutubeURL.bind(this)}
              editFlag={true}
              changeCheckedSubUnit={this.changeCheckedSubUnit.bind(this)}
              changeCheckedUnit={this.changeCheckedUnit.bind(this)}
              checkedSubUnits={checkedSubUnits} />
            </div>
          </div>
        </div>
        <YoutubeModal isActive={this.props.isYoutubeModal} onClose={this.closeYoutubeModal.bind(this)} youtubeURL={this.props.youtubeURL} />
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "生徒詳細", url: "/student"}, {label: "カリキュラム設定"}],
    access_token: state.requestAccessToken.access_token,
    box_id: state.requestCurriculums.box_id,
    student: state.requestCurriculums.student,
    agreement: state.requestCurriculums.agreement,
    sub_subjects: state.requestCurriculums.sub_subjects,
    curriculum: state.requestCurriculums.curriculum,
    learnings: state.requestCurriculums.learnings,
    isYoutubeModal: state.requestCurriculums.isYoutubeModal,
    isSettingModal: state.requestCurriculums.isSettingModal,
    selected_student_id: state.requestBoxes.selected_student_id,
    selected_box_id: state.requestBoxes.selected_box_id,
    selected_subject_id: state.requestBoxes.selected_subject_id,
    selected_schoolyear_key: state.requestBoxes.selected_schoolyear_key,
    selected_agreement_id: state.requestBoxes.selected_agreement_id,
    youtubeURL: state.requestCurriculums.youtubeURL,
    setLearnings: state.requestLearnings.setLearnings,
    pdfListBtnDisable: state.requestLearnings.pdfListBtnDisable,
    checkedSubUnits: state.requestCurriculums.checkedSubUnits,
    isCalStartActive: state.requestCurriculums.isCalStartActive,
    isCalEndActive: state.requestCurriculums.isCalEndActive,
    numberOfWeeks: state.requestNumberOfWeeks.numberOfWeeks,
    curEditStartDate: state.requestCurriculums.curEditStartDate,
    curEditEndDate: state.requestCurriculums.curEditEndDate,
    selected_sub_subject_key: state.requestCurriculums.selected_sub_subject_key,
    selected_sub_subject_name: state.requestCurriculums.selected_sub_subject_name
  }
}

export default connect(mapStateToProps)(CurriculumEdit);
