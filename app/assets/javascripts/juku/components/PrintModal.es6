import React, { Component } from 'react'
import { connect } from 'react-redux'
import classNames from 'classnames'

export class PrintModal extends Component {

  constructor(props) {
    super(props)
  }

  closeModal(e) {
    this.props.onClose()
  }

  onOpenPdf(url) {
    window.open(url)
    this.props.onClose()
  }

  getPdfheading(learning, heading_key){
    let pdfs = []
    if(heading_key == 'heading_practice' && learning.sub_units[0].videos[0]['practice_url'] == null) {
      return []
    }
    let heading_pdf = learning.sub_units[0].videos[0][heading_key]
    if(heading_pdf !== null && heading_pdf !== '' && heading_pdf !== undefined ) {
      pdfs.push({ "url": learning.sub_units[0].videos[0][heading_key] })
    }
    return pdfs
  }
  getPdfsFromLearning(learning, text_key, checktest_key){
    let pdfs = []
    learning.sub_units.map((sub_unit) => {
      sub_unit.videos.map((video) => {
        if(video[text_key] !== null && video[text_key] !== '' &&  video[text_key] !== undefined ) {
          pdfs.push({"url": video[text_key]})
        }
        if(video[checktest_key] !== null && video[checktest_key] !== '' && video[checktest_key] !== undefined) {
          pdfs.push({ "url": video[checktest_key] })
        }
      })
    })
    return pdfs
  }

  render() {
    const { errorMessage, joinedPdfResponceStatus, isActive, curriculums, isJoinedPdfStatus, joinedPdfUrl, isHaveReport } = this.props
    let modalClass = classNames('Modal', {active: isActive})
    let modalContainerClass = classNames('Modal__container print', {active: isActive})
    let lessonPdfsArray = []
    let lessonAnswerPdfsArray = []
    let practicePdfsArray = []
    let practicePdfsAnsArray = []
    let pdfLinks = []
    let printDom
    let heading_lessontext = []
    let heading_lessontext_ans = []
    let heading_practice = []
    console.log('PrintModal#render')
    console.log('curriculums')
    console.log(curriculums)
    if( curriculums !==　undefined && curriculums !==　null && curriculums.length > 0 ) {
      curriculums.map((curriculum) => {
        let units = curriculum.learnings.units
        if(units.length > 0) {
          units.map((unit) => {
            if(unit.sub_units[0].videos[0]){
              if( heading_lessontext.length === 0 ) {
                heading_lessontext = this.getPdfheading(unit, 'heading_lessontext')
              }
              if( heading_lessontext_ans.length === 0 ) {
                heading_lessontext_ans = this.getPdfheading(unit, 'heading_lessontext_ans')
              }
              if( heading_practice.length === 0 ) {
                heading_practice = this.getPdfheading(unit, 'heading_practice')
              }
              let lessonPdfs = this.getPdfsFromLearning(unit, 'lesson_text_url', 'checktest_url')
              let lessonAnswerPdfs = this.getPdfsFromLearning(unit, 'lesson_text_answer_url', 'checktest_answer_url')
              let practicePdfs = this.getPdfsFromLearning(unit, 'practice_url')
              let practicePdfsAns = this.getPdfsFromLearning(unit, 'practice_answer_url')
              lessonPdfsArray = lessonPdfsArray.concat( lessonPdfs )
              lessonAnswerPdfsArray = lessonAnswerPdfsArray.concat( lessonAnswerPdfs )
              practicePdfsArray = practicePdfsArray.concat( practicePdfs)
              practicePdfsAnsArray  = practicePdfsAnsArray.concat( practicePdfsAns )

              console.log('pdf_array')
              console.log(lessonPdfsArray)
              console.log(lessonAnswerPdfsArray)
              console.log(practicePdfsArray)
              console.log(practicePdfsAnsArray)
            }
          })
        }
      })
      pdfLinks = pdfLinks.concat(heading_lessontext, lessonPdfsArray, heading_lessontext_ans, lessonAnswerPdfsArray, heading_practice, practicePdfsArray, practicePdfsAnsArray)
      console.log('pdf links')
      console.log(pdfLinks)
    }
    if(pdfLinks.length > 0) {
      if(pdfLinks.length == 1) {
        printDom = <div className="print">
              <p>印刷しますか？</p>
              <ul className="buttons">
                <li><button className="el-button size-modal color-pink" onClick={this.onOpenPdf.bind(this, pdfLinks[0].url)}>はい</button></li>
                <li><button className="el-button size-modal color-return" onClick={(e) => this.closeModal()}>いいえ</button></li>
              </ul>
            </div>
      } else {
        printDom = <div className="print">
              <p>処理には数秒から数十秒かかります。本当に印刷しますか？</p>
              <ul className="buttons">
                <li><button className="el-button size-modal color-pink" onClick={(e) => this.props.onGetPdfLink(pdfLinks)}>はい</button></li>
                <li><button className="el-button size-modal color-return" onClick={(e) => this.closeModal()}>いいえ</button></li>
              </ul>
            </div>
      }
    } else {
      printDom = <div className="print">
              <p>関連するpdfファイルがありません。</p>
              <button className="el-button size-modal" onClick={(e) => this.closeModal()}>閉じる</button>
            </div>
    }

    if(isJoinedPdfStatus == 'loading') {
      printDom = <div className="print">
              {isHaveReport? (<p>学習報告書と問題のpdfを用意しています</p>) : (<p>問題のpdfを用意しています</p>)}
              <p>{pdfLinks.length}個のPDFを結合中</p>
              <p className="loading"></p>
            </div>
    }
    if(isJoinedPdfStatus == 'yes') {
      printDom = <div className="print">
        <a className="el-button size-modal color-pink" href={joinedPdfUrl} target="_blank" onClick={(e) => isHaveReport && window.print() } >pdfを開く</a>
      </div>
    }

    if(isJoinedPdfStatus == 'no') {
      let message
      if(errorMessage != '') {
        message = errorMessage
      } else {
        message = 'PDF生成処理がタイムアウトしました。しばらく時間をおいてから再実行してください'
      }
      printDom = <div className="print">
              <p>{message}</p>
            </div>
    }
    return (
      <div className={modalClass}>
        <div className={modalContainerClass}>
          <button className="Modal__close" onClick={(e) => this.closeModal()} />
          {isHaveReport? (<h2 className="Modal__title">学習報告書と問題を印刷</h2>) : (<h2 className="Modal__title">設定した授業の問題を全て印刷</h2>)}
          <div className="Modal__contents">
            {printDom}
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

export default connect(mapStateToProps)(PrintModal);
