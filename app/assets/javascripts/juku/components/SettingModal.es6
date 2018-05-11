import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

export class SettingModal extends Component {

  constructor(props) {
    super(props)
  }

  closeModal(e) {
    this.props.onClose()
  }

  // todo: いらない引数削除する
  returnSettingBtn(status, learning_id, box_id, sent_on, student_id, period_id, sub_unit_id) {
    let settingBtnDom
    switch(status) {
      case 'sent':
      case 'pass':
      case 'failure':
        settingBtnDom = <input type="button" className="el-button size-setting color-light" value="今日の対象外" 
        onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'scheduled')} />
        break;
      case 'scheduled':
      case null:
      default:
        settingBtnDom = <div><input type="button" className="el-button size-setting icon-return color-return" value="もとにもどす" 
        onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'sent')} /><p className="note">※この授業分は印刷されません</p></div>
        break;
    }
    return settingBtnDom
  }

  returnStatusBtns(status, learning_id) {
    let statusBtns
    switch(status) {
      case 'pass':
        statusBtns = <ul className="btns">
            <li><a className="icon-review-off" onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'failure')} /></li>
            <li><i className="icon-pass-on" /></li>
          </ul>
        break;
      case 'failure':
        statusBtns = <ul className="btns">
            <li><i className="icon-review-on" /></li>
            <li><a className="icon-pass-off" onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'pass')} /></li>
          </ul>
        break;
      default:
        statusBtns = <ul className="btns">
            <li><a className="icon-review-off" onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'failure')} /></li>
            <li><a className="icon-pass-off" onClick={(e) => this.props.onSetLearningStatus(this.props.setLearnings, learning_id, 'pass')} /></li>
          </ul>
        break;
    }
    return statusBtns
  }

  // onSetLearningStatus(setLearnings, learning_id, status){
  //   const { dispatch } = this.props
  //   dispatch(changeSetLearnings(learning_id, status))
  // setLearnings自体を変更するdispatchをここで発火させる

  returnReportItemClassName(status) {
    let reportItemClassName
    let isPink = false
    switch(status){
      case 'sent':
      case 'pass':
      case 'failure':
        break;
      case 'scheduled':
      case null:
      default:
        isPink = true
        break;
    }
    reportItemClassName = classNames("report-item", {pink: isPink})
    return reportItemClassName
  }

  returnZeroLearnings(setLearnings) {
    if(setLearnings.length == 0) {
      return <p className="note">授業が1つも設定されていません。</p>
    }
  }

  render() {
    const { isActive, setLearnings, pdfListBtnDisable } = this.props
    let modalClass = classNames('Modal', {active: isActive})
    let modalContainerClass = classNames('Modal__container', {active: isActive})
    let pdfListBtnDisableClassName = classNames("el-button size-modal color-pink icon-print", { 'color-disabled': pdfListBtnDisable})
    return (
      <div className={modalClass}>
        <div className={modalContainerClass}>
          <button className="Modal__close" onClick={(e) => this.closeModal()} />
          <h2 className="Modal__title">「合格」「後で復習」を選択してください</h2>
          <div className="Modal__contents">
            <div className="appraisal">
              <h3 className="title">評価基準</h3>
              <p className="example"><i href="#" className="icon-pass-on" /><span>プリントが全問正解だった場合</span></p>
              <p className="example"><i href="#" className="icon-review-on" /><span>プリントで1問でも間違いがある場合</span></p>
              <p className="caption">最終的なテスト結果で「後で復習」「合格」を判断してください。</p>
            </div>
            {setLearnings.map((learning, i) => {
              return <div key={i}>
                <h3 className="subsubject">{learning.unit_name}</h3>
                {learning.sub_units.map((sub_unit, j) => {
                  return <div className={this.returnReportItemClassName(sub_unit.learning_status)} key={j}>
                      <div className="report-item-left">
                        <h4 className="caption-title">{sub_unit.sub_unit_name}</h4>
                        <p className="caption">{sub_unit.sub_unit_goal}</p>
                        {this.returnSettingBtn(sub_unit.learning_status, sub_unit.learning_id, sub_unit.box_id, sub_unit.sent_on, this.props.student_id, this.props.period_id, sub_unit.sub_unit_id)}
                      </div>
                      <div className="report-item-right">
                        {this.returnStatusBtns(sub_unit.learning_status, sub_unit.learning_id)}
                      </div>
                    </div>
                })}
              </div>
            })}
            {this.returnZeroLearnings(setLearnings)}
            {(() => {
              let statusFlag = true
              let statusArray = []
              let scheduledNum = 0
              setLearnings.map(learning => learning.sub_units.map(sub_unit => {
                statusArray.push(sub_unit.learning_status)
                if(sub_unit.learning_status != 'pass' && sub_unit.learning_status != 'failure' && sub_unit.learning_status != 'scheduled') {
                  statusFlag = false
                  return
                }
              }))
              for (let i=0; i < statusArray.length; i++) {
                if(statusArray[i] == 'scheduled') {
                  scheduledNum++
                }
              }
              if(scheduledNum == statusArray.length) {
                statusFlag = false
              }

              if(setLearnings.length > 0 && statusFlag) {
                return <div className="report-footer">
                  <p className="caption">今日の授業は全て含まれていますか？<br />
                  含まれていない場合は、「＋今日の授業に設定」で設定してください。</p>
                  <input type="checkbox" id="report_ok" onChange={(e) => {
                    this.props.onChangePdfListDisable(!e.target.checked)
                  }} /><label htmlFor="report_ok">今日の授業が全て含まれていることを確認しました。</label>
                  <ul className="buttons">
                    <li><input type="button" value="設定しなおす" className="el-button size-modal color-return" onClick={(e) => this.closeModal()} /></li>
                    <li><input type="button" value="決定して印刷" className={pdfListBtnDisableClassName} disabled={pdfListBtnDisable} onClick={this.props.onPostLearningReport} /></li>
                  </ul>
                </div>
              } else {
                return <div className="report-footer">
                  <ul className="buttons">
                    <li><input type="button" value="設定しなおす" className="el-button size-modal color-return" onClick={(e) => this.closeModal()} /></li>
                    <li></li>
                  </ul>
                </div>
              }
            })()}
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    isActive,
    newSetLearnings,
    pdfListBtnDisable: state.requestLearnings.pdfListBtnDisable,
    setLearnings: state.requestLearnings.setLearnings
  }
}


export default connect(mapStateToProps)(SettingModal);