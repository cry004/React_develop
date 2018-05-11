import React, { Component } from 'react'
import { Link } from 'react-router-dom'
import { connect } from 'react-redux'

import { requestStudents } from '../../actions/Students.es6'
import { Breadcrumbs } from '../../components/Breadcrumbs.es6'
import { SystemMenu } from '../../components/SystemMenu.es6'
import { Loading } from '../../components/Loading.es6'
import { Search } from './Search.es6'
import { List } from './List.es6'


export class Students extends Component {

  constructor(props) {
    super(props)
  }

  componentDidMount() {
    const { dispatch, classroom_id, access_token } = this.props
    dispatch(requestStudents(classroom_id, access_token))
  }

  render() {
    const { dispatch,
            breadcrumbs,
            location,
            students,
            periods,
            searched_students,
            search_text,
            isFetchedStudents
          }　= this.props
    return (
      <div className="Content">
        <Breadcrumbs items={breadcrumbs} />
        <div className="Students__container">
          <SystemMenu pathname={location.pathname} />
          <Loading isFetched={isFetchedStudents} />
          <div className="Students">
            <div className="Schedule__header">
              <Search dispatch={dispatch} searchText={search_text} students={students} />
            </div>
            <List searched_students={searched_students} periods={periods} />
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    breadcrumbs: [{label: "管理システムTOP", url: "/room", invisible: state.requestAccessToken.isFromTryPlus}, {label: state.requestRooms.selectedRoomName, url: "/schedule"}, {label: "生徒一覧"}],
    classroom_id: state.requestRooms.selectedRoom,
    access_token: state.requestAccessToken.access_token,
    search_text: state.requestStudents.search_text,
    students: state.requestStudents.students,
    periods: state.requestStudents.periods,
    searched_students: state.requestStudents.searched_students,
    isFetchedStudents: state.requestStudents.isFetchedStudents
  }
}

export default connect(mapStateToProps)(Students);
