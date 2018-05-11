import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { connect } from 'react-redux'
import moment from 'moment'

import { changeStartDate, changeEndDate, changeCalActive, requestSubjects, setCheckedSubUnits, changeIsCalStartActive, changeIsCalEndActive } from '../../actions/Simulator.es6'
import { requestNumberOfWeeks } from '../../actions/NumberOfWeeks.es6'
import { Breadcrumbs } from '../../components/Breadcrumbs.es6'
import { SystemMenu } from '../../components/SystemMenu.es6'
import { Loading } from '../../components/Loading.es6'
import { Dates } from './Dates.es6'
import { Unit } from './Unit.es6'

export class Simulator extends Component {

  constructor(props) {
    super(props)
  }

  componentDidMount() {
    const { dispatch, access_token, subject_val } = this.props
    dispatch(requestSubjects(access_token, "c1_english_regular"))
    dispatch(setCheckedSubUnits([]))
    this.hideCalAndChangeStartDate(moment().format('YYYY-MM-DD'))
    this.hideCalAndChangeEndDate(moment().add(3, 'months').format('YYYY-MM-DD'))
  }

  onSetCalStartActive(isCalStartActive) {
    const { dispatch, isCalEndActive } = this.props
    dispatch(changeCalActive(isCalStartActive, isCalEndActive))
  }

  onSetCalEndActive(isCalEndActive) {
    const { dispatch, isCalStartActive } = this.props
    dispatch(changeCalActive(isCalStartActive, isCalEndActive))
  }

  hideCalAndChangeStartDate(startDate) {
    const { dispatch, access_token, end_date } = this.props

    if(end_date > startDate || end_date == ''){
      dispatch(changeStartDate(moment(startDate).format('YYYY-MM-DD')))
      dispatch(requestNumberOfWeeks(access_token, startDate, end_date))
      dispatch(changeIsCalStartActive(false))
    }
  }

  hideCalAndChangeEndDate(endDate) {
    const { dispatch, access_token, start_date } = this.props
    if(start_date < endDate || start_date == ''){
      dispatch(changeEndDate(moment(endDate).format('YYYY-MM-DD')))
      dispatch(requestNumberOfWeeks(access_token, start_date, endDate))
      dispatch(changeIsCalEndActive(false))
    }
  }

  changeCheckedUnit(unit_id, bool){
    const { dispatch, units, checkedSubUnits } = this.props
    let newCheckedSubUnits = checkedSubUnits.concat()
    let sub_units
    units.map((unit) => {
      if(unit.unit_id == unit_id){
        sub_units = unit.sub_units
      }
    })
    sub_units.map((sub_unit) => {
      let index = newCheckedSubUnits.indexOf(sub_unit.sub_unit_id)
      if(bool){
        if (index < 0){
          newCheckedSubUnits.push(sub_unit.sub_unit_id)
        }
      }else{
        if (index > -1){
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

  changeSubject(subject_val) {
    const { dispatch, access_token } = this.props
    dispatch(requestSubjects(access_token, subject_val))
    this.resetCheckBox()
  }

  resetCheckBox() {
    let checkBoxes = document.getElementsByClassName("js-unit-checkbox")
    for(let i=0; i<checkBoxes.length; i++) {
      checkBoxes.item(i).checked = false;
    }
    const { dispatch } = this.props
    dispatch(setCheckedSubUnits([]))
  }

  returnAverageCurriculumNum(checkedSubUnitsLength, numberOfWeeks){
    let averageCurriculumNum = [0,0,0,0,0]//1枠〜5枠の時一週間に見る動画の本数
    if(numberOfWeeks > 0){
      for(let i=0; i<averageCurriculumNum.length; i++) {
        averageCurriculumNum[i] =　this.floatFormat( Number(checkedSubUnitsLength)/Number(numberOfWeeks)/(i+1), 2)
      }
    }
    return averageCurriculumNum
  }

  /**
   *  @param (Number)number 実数
   *  @param (Number)n 小数第n位で四捨五入
   *  @return 四捨五入された数
   */
  floatFormat(number, n) {
    let _pow = Math.pow(10, n-1)
    return Math.round(number * _pow) / _pow
  }

  render() {
    const { breadcrumbs,
            location,
            isCalStartActive,
            isCalEndActive,
            start_date,
            end_date,
            sub_subjects,
            units,
            checkedSubUnits,
            numberOfWeeks,
            dispatch,
            isFetchedSubjects } = this.props

    let totalMovies = checkedSubUnits.length
    let movie_counts = this.returnAverageCurriculumNum(checkedSubUnits.length, numberOfWeeks)

    return (
      <div className="Content">
        <Breadcrumbs items={breadcrumbs} />
        <div className="Simulator__container">
          <SystemMenu pathname={location.pathname} />
          <Loading isFetched={isFetchedSubjects} />
          <div className="Schedule__contents">
            <div className="Schedule__header">
              <p className="average-movie">
                一週間に
                <span className="big">
                  {movie_counts[0]}
                </span>
                本の映像授業をみる必要があります。
              </p>
              <div className="movie-week">
                {movie_counts.map((count, i) =>
                  <p className="movie-count" key={i}>{i+1}枠のとき
                    <span>
                      {movie_counts[i]}
                    </span>
                    本
                  </p>
                )}
              </div>
              <p className="description">
                生徒が予定する枠数に応じて、１回の授業でみる必要がある映像授業数を表示しています。
              </p>
            </div>
            <div className="Simulator">
              <div className="container l-clearfix">
                <div className="text">
                  <p className="number">
                    条件①
                  </p>
                  <p className="description">
                    期間を設定してください。
                  </p>
                </div>
                <div className="select">
                  <Dates
                    this_date={start_date}
                    isCalActive={isCalStartActive}
                    onSetEditCalActive={this.onSetCalStartActive.bind(this)}
                    onCalChange={this.hideCalAndChangeStartDate.bind(this)}
                  />
                  〜
                  <Dates
                    this_date={end_date}
                    isCalActive={isCalEndActive}
                    onSetEditCalActive={this.onSetCalEndActive.bind(this)}
                    onCalChange={this.hideCalAndChangeEndDate.bind(this)}
                  />
                </div>
                <p className="total">
                  <span>
                    {numberOfWeeks}
                  </span>
                  週
                </p>
              </div>

              <div className="container l-clearfix">
                <div className="text">
                  <p className="number">
                    条件②
                  </p>
                  <p className="description">
                    科目と授業を選択してください。
                  </p>
                </div>
                <div className="select">
                  <select className="el-select" onChange={e => this.changeSubject(e.target.value)}>
                    {sub_subjects.map((subject,i) =>
                      <option value={subject.sub_subject_key} key={i}>
                        {subject.sub_subject_name}
                      </option>)
                    }
                  </select>
                </div>
                <p className="total">
                  <span>
                    {totalMovies}
                  </span>
                  本
                </p>
              </div>
              <div className="curriculumList">
                {units.map((unit, i) =>
                  <Unit unit={unit} key={i} checkedSubUnits={checkedSubUnits} changeCheckedSubUnit={this.changeCheckedSubUnit.bind(this)} changeCheckedUnit={this.changeCheckedUnit.bind(this)} />
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "カリキュラムシミュレータ"}],
    access_token: state.requestAccessToken.access_token,
    isCalActive: state.requestSimulator.isCalActive,
    isCalStartActive: state.requestSimulator.isCalStartActive,
    isCalEndActive: state.requestSimulator.isCalEndActive,
    start_date: state.requestSimulator.start_date,
    end_date: state.requestSimulator.end_date,
    sub_subjects: state.requestSimulator.sub_subjects,
    units: state.requestSimulator.units,
    numberOfWeeks: state.requestNumberOfWeeks.numberOfWeeks,
    checkedSubUnits: state.requestSimulator.checkedSubUnits,
    subject_val: state.requestSimulator.subject_val,
    isFetchedSubjects: state.requestSimulator.isFetchedSubjects
  }
}

export default connect(mapStateToProps)(Simulator);
