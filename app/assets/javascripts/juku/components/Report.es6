import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { connect } from 'react-redux'
import moment from 'moment'

import { requestLearningReports, initIsFetchedReport } from '../actions/Reports.es6'
import { requestCurriculums, setPdfModal } from '../actions/Curriculums.es6'
import { joinPdfs, setDefaultPdf } from '../actions/Pdf.es6'
import { PrintModal } from '../components/PrintModal.es6'
import { initErrorMessage } from '../actions/ErrorMessage.es6'
import { Breadcrumbs } from '../components/Breadcrumbs.es6'
import { Loading } from '../components/Loading.es6'

export class Report extends Component {

  constructor(props) {
    super(props)
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

  componentWillMount() {
    const { dispatch, access_token, selected_box_id, selected_agreement_id, reported_at, selected_subject_id } = this.props
    dispatch(requestLearningReports(access_token,
      selected_box_id,
      selected_agreement_id,
      reported_at,
      selected_subject_id))
  }

  componentWillUnmount() {
    const { dispatch } = this.props
    this.closePrintModal()
    dispatch(initIsFetchedReport())
    dispatch(initErrorMessage())
  }
  componentDidMount() {
    window.scrollTo(0, 0)
  }
  printPage() {
    window.print()
  }

  render() {
    const { errorMessage, joinedPdfResponceStatus, joinedPdfUrl, setLearnings, isJoinedPdfStatus, curriculums, student, agreement, curriculum, e_navis, selectedRoomName, report_date, selected_agreement_id, isFetchedReport } = this.props
    const itemsLength = 12
    let reviews = Object.keys(e_navis).length ? e_navis.reviews : []
    let challenges = Object.keys(e_navis).length ? e_navis.challenges : []
    let setLearningsArray = []
    let unitName
    let nspace


    curriculums.map((curriculum) => {
      curriculum.learnings.units.map((unit) => {
        unitName = unit.unit_name
        unit.sub_units.map((sub_unit) => {
          sub_unit.unit_name = unitName
          setLearningsArray.push(sub_unit);
        })
      })
    })
    if( setLearningsArray.length <= itemsLength ){
      nspace = itemsLength - setLearningsArray.length
      setLearningsArray = [ ...setLearningsArray, ...Array(nspace).fill('')]
    }else{
      nspace = itemsLength * 2 - setLearningsArray.length
      if( nspace > 0 ){
        setLearningsArray = [ ...setLearningsArray, ...Array(nspace).fill('')]
      }else{
        setLearningsArray = [ ...setLearningsArray.slice(0, 24)]
      }
    }
    return(
      <div className="Report" >
        <Breadcrumbs items={this.props.breadcrumbs} />
        <Loading isFetched={isFetchedReport} />
        <div className="Report__container">
          <div className="Curriculums__header">
            <div className="Curriculums__header-left">
              <p className="avatar"><img src={student.avatar_url} width="49" height="49"/></p>
              <div className="info-1">
                <p className="name">{student.student_name}さん</p>
                <p className="grade">{student.schoolyear}</p>
                <Link to="/history" className="history">この生徒の学習履歴を見る</Link>
              </div>
              <div className="info-2">
                <p className="date">{agreement.agreement_dow_name} {agreement.start_time}~{agreement.end_time}</p>
                <p className="subject">{agreement.subject_name}</p>
              </div>
            </div>
            <div className="Curriculums__header-right">
              <input type="button" className="el-button icon-print color-white" value="この学習報告書のみを印刷" onClick={(e) => this.printPage()} />
              <input type="button" className="el-button icon-print color-pink" value="学習報告書と問題を印刷" onClick={(e) => this.onSetPdfModal(true)} />
            </div>
          </div>
          <div className="Report__contents">
            <h1 className="Report__title">日次学習報告書</h1>
            <div className="Report__header">
              <div className="Report__header-left">
                <p className="avatar"><img src={student.avatar_url} width="67" height="67"/></p>
                <div className="profile">
                  <p className="name">{student.student_name}さん</p>
                  <p className="date">{student.schoolyear}</p>
                </div>
              </div>
              <div className="Report__header-right">
                <div className="info">
                  <p className="school">{selectedRoomName}</p>
                  <p className="date">{moment(report_date).format('YYYY年MM月DD日（ddd）')}</p>
                  <p className="time">自立学習 {agreement.start_time} 〜 {agreement.end_time}</p>
                  { agreement.end_time && parseInt(agreement.end_time.split(":")[1]) + 10 < 60 ?
                  ( <p className="time">演習 { agreement.end_time.split(":")[0]}:{ parseInt(agreement.end_time.split(":")[1])+10} 〜 { parseInt(agreement.end_time.split(":")[0])+1}:{ agreement.end_time.split(":")[1]}</p> ) :
                  ( <p className="time">演習 {agreement.end_time && parseInt(agreement.end_time.split(":")[0])+1}:{agreement.end_time && parseInt(agreement.end_time.split(":")[1])-60} 〜 {agreement.end_time && parseInt(agreement.end_time.split(":")[0])+1}:{agreement.end_time && agreement.end_time.split(":")[1]}</p> )
                  }
                </div>
                <div className="sign">
                  <div className="space"><div className="space__title">自立学習<br />コーチ</div></div>
                  <div className="space"><div className="space__title">演習<br />コーチ</div></div>
                </div>
              </div>
            </div>
            <h2 className="Report__subtitle">今日の学習内容</h2>
              <div className="Report__table">
              {setLearningsArray.map((sub_unit, sub_unitIndex) =>
                sub_unitIndex < itemsLength &&
                <div className="Report__table-cell" key={sub_unitIndex}>
                  <div className="Report__table-title">
                    {sub_unit.sub_unit_name ? (
                      sub_unit.unit_name) : ("\u00a0")
                     }
                  </div>
                  <div className="Report__table-unit-title">{sub_unitIndex+1}. {sub_unit.sub_unit_name}</div>
                  {sub_unit.videos &&
                    sub_unit.videos.map((video, videoIndex) => {
                      return <div className="Report__table-unit-subtitle" key={videoIndex}>{video.video_name}</div>
                    })
                  }
                  <table className="Report__table-curriculum-setting">
                    <thead>
                      <tr><th colSpan={2}>自立学習</th></tr>
                      <tr>
                        <th>合格</th>
                        <th>後で復習</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td></td>
                        <td></td>
                      </tr>
                    </tbody>
                  </table>
                  <table className="Report__table-curriculum-setting">
                    <thead>
                      <tr><th rowSpan={2}>演習</th></tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}
            </div>

            <h2 className="Report__subtitle enavi">今日の学習内容に関連するeNAVI<span className="note"></span></h2>
            <div className="Report__curriculums-contents">
              <table className="enavi test">
                <thead>
                  <tr>
                    <th colSpan={2}>▼ もっと演習しよう</th>
                  </tr>
                  <tr>
                  <th>分野<hr/></th>
                  <th>単元<hr/></th>
                  </tr>
                </thead>
                <tbody>
                  {reviews.map((review, reviewIndex) =>
                    reviewIndex < 10 &&
                    <tr key={reviewIndex}>
                      <td><div>・{review.section_name}</div></td>
                      <td><div>・{review.content_name}</div></td>
                    </tr>
                  )}
                </tbody>
              </table>
              <table className="enavi test">
                <thead>
                  <tr>
                    <th colSpan={2}>▼ チャレンジしよう</th>
                  </tr>
                  <tr>
                    <th>分野<hr/></th>
                    <th>単元<hr/></th>
                  </tr>
                </thead>
                <tbody>
                  {challenges.map((challenge, challengeIndex) =>
                    challengeIndex < 10 &&
                      <tr key={challengeIndex}>
                        <td><div>・{challenge.section_name}</div></td>
                        <td><div>・{challenge.content_name}</div></td>
                      </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          { setLearningsArray.length > itemsLength &&
            <div className="Report__contents">
              <h1 className="Report__title">日次学習報告書</h1>
              <div className="Report__header">
                <div className="Report__header-left">
                  <p className="avatar"><img src={student.avatar_url} width="67" height="67"/></p>
                  <div className="profile">
                    <p className="name">{student.student_name}さん</p>
                    <p className="date">{student.schoolyear}</p>
                  </div>
                </div>
                <div className="Report__header-right">
                  <div className="info">
                    <p className="school">{selectedRoomName}</p>
                    <p className="date">{moment(report_date).format('YYYY年MM月DD日（ddd）')}</p>
                    <p className="time">自立学習 {agreement.start_time} 〜 {agreement.end_time}</p>
                    { agreement.end_time && parseInt(agreement.end_time.split(":")[1]) + 10 < 60 ?
                    ( <p className="time">演習 { agreement.end_time.split(":")[0]}:{ parseInt(agreement.end_time.split(":")[1])+10} 〜 { parseInt(agreement.end_time.split(":")[0])+1}:{ agreement.end_time.split(":")[1]}</p> ) :
                    ( <p className="time">演習 {agreement.end_time && parseInt(agreement.end_time.split(":")[0])+1}:{ agreement.end_time && parseInt(agreement.end_time.split(":")[1])-60} 〜 {agreement.end_time && parseInt(agreement.end_time.split(":")[0])+1}:{agreement.end_time && agreement.end_time.split(":")[1]}</p> )
                    }
                  </div>
                  <div className="sign">
                    <div className="space"><div className="space__title">自立学習<br />コーチ</div></div>
                    <div className="space"><div className="space__title">演習<br />コーチ</div></div>
                  </div>
                </div>
              </div>
              <h2 className="Report__subtitle">今日の学習内容</h2>
                <div className="Report__table">
                {setLearningsArray.map((sub_unit, sub_unitIndex) =>
                  sub_unitIndex >= itemsLength &&
                  <div className="Report__table-cell" key={sub_unitIndex}>
                    <div className="Report__table-title">
                      {sub_unit.sub_unit_name ? (
                        sub_unit.unit_name) : ("\u00a0")
                       }
                    </div>
                    <div className="Report__table-unit-title">{sub_unitIndex + 1}. {sub_unit.sub_unit_name}</div>
                    {sub_unit.videos &&
                      sub_unit.videos.map((video, videoIndex) => {
                        return <div className="Report__table-unit-subtitle" key={videoIndex}>{video.video_name}</div>
                      })
                    }
                    <table className="Report__table-curriculum-setting">
                      <thead>
                        <tr><th colSpan={2}>自立学習</th></tr>
                        <tr>
                          <th>合格</th>
                          <th>後で復習</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td></td>
                          <td></td>
                        </tr>
                      </tbody>
                    </table>
                    <table className="Report__table-curriculum-setting">
                      <thead>
                        <tr><th rowSpan={2}>演習</th></tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                )}
              </div>


              <h2 className="Report__subtitle enavi">今日の学習内容に関連するeNAVI<span className="note"></span></h2>
              <div className="Report__curriculums-contents">
                <table className="enavi test">
                  <thead>
                    <tr>
                      <th colSpan={2}>▼ もっと演習しよう</th>
                    </tr>
                    <tr>
                    <th>分野<hr/></th>
                    <th>単元<hr/></th>
                    </tr>
                  </thead>
                  <tbody>
                    {reviews.map((review, reviewIndex) =>
                      reviewIndex > 9 && reviewIndex < 20 &&
                      <tr key={reviewIndex}>
                        <td><div>・{review.section_name}</div></td>
                        <td><div>・{review.content_name}</div></td>
                      </tr>
                    )}
                  </tbody>
                </table>
                <table className="enavi test">
                  <thead>
                    <tr>
                      <th colSpan={2}>▼ チャレンジしよう</th>
                    </tr>
                    <tr>
                      <th>分野<hr/></th>
                      <th>単元<hr/></th>
                    </tr>
                  </thead>
                  <tbody>
                    {challenges.map((challenge, challengeIndex) =>
                      challengeIndex > 9 && challengeIndex < 20 &&
                        <tr key={challengeIndex}>
                          <td><div>・{challenge.section_name}</div></td>
                          <td><div>・{challenge.content_name}</div></td>
                        </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          }
        </div>
        <PrintModal errorMessage={errorMessage} isHaveReport={true} joinedPdfResponceStatus={joinedPdfResponceStatus} joinedPdfUrl={joinedPdfUrl} isJoinedPdfStatus={isJoinedPdfStatus} setLearnings={setLearnings} curriculums={this.props.curriculums} isActive={this.props.isPdfModal} onClose={this.closePrintModal.bind(this)} onGetPdfLink={this.getPdfLink.bind(this)} />
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    access_token: state.requestAccessToken.access_token,
    selected_box_id: state.requestBoxes.selected_box_id,
    selected_subject_id: state.requestBoxes.selected_subject_id,
    selected_agreement_id: state.requestBoxes.selected_agreement_id,
    box_id: state.requestLearningReports.box_id,
    student: state.requestLearningReports.student,
    agreement: state.requestLearningReports.agreement,
    curriculums: state.requestLearningReports.curriculums,
    learnings: state.requestLearningReports.learnings,
    e_navis: state.requestLearningReports.e_navis,
    curriculum: state.requestCurriculums.curriculum,
    setLearnings: state.requestLearnings.setLearnings,
    selected_student_id: state.requestBoxes.selected_student_id,
    joinedPdfUrl: state.requestPdf.joinedPdfUrl,
    isJoinedPdfStatus: state.requestPdf.isJoinedPdfStatus,
    joinedPdfResponceStatus: state.requestPdf.joinedPdfResponceStatus,
    isPdfModal: state.requestCurriculums.isPdfModal,
    errorMessage: state.requestPdf.errorMessage,
    selectedRoomName: state.requestRooms.selectedRoomName,
    report_date: state.requestLearningReports.report_date,
    reported_at: state.requestLearningReports.reported_at,
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "生徒詳細", url: "/student"}, {label: "日次学習報告書"}],
    isFetchedReport: state.requestLearningReports.isFetchedReport
  }
}

export default connect(mapStateToProps)(Report);
