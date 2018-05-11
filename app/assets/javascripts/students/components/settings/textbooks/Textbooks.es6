import React, { Component } from 'react'
import { connect } from 'react-redux'

import { Subject } from './Subject.es6'

import { requestSchoolbooks,
  updateSchoolbooksSetting } from '../../../actions/user.es6'

class SettingsTextbooks extends Component {
  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestSchoolbooks(accessToken.accessToken))
  }
  selectBook(selectSubject, bookname) {
    const { user, accessToken, dispatch } = this.props
    let subjectObj = {}
    let schoolbooks = {}
    let selectedSubjectName = selectSubject 
    if (!!user.schoolbooks.schoolyears[0]) {
      user.schoolbooks.schoolyears[0].subjects.forEach((subject, i) => {
        subject.schoolbooks.forEach((book, j) => {
          if (book.selected_flag === true) {
            subjectObj[subject.key] = {"name": book.display_name}    
          }
        })
      })
    }
    subjectObj[selectedSubjectName] = {"name": bookname}
    schoolbooks["c1"] = subjectObj
    dispatch(updateSchoolbooksSetting(accessToken.accessToken, schoolbooks, selectSubject, bookname))
  }
  render() {
    const { user } = this.props
    return (
      <div className="page-settings-textbooks">
        <h1 className="heading">教科書の設定（中学生のみ）</h1>
        {(() => {
          if(!!user.schoolbooks.schoolyears[0]) {
            return (
              <div className="cards">
                {user.schoolbooks.schoolyears[0].subjects.map((subject, i) =>
                  <Subject key={i} subject={subject} selectBook={this.selectBook.bind(this)}/>
                )}
              </div>
            )
          }
        })()}
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    user: state.user,
    accessToken: state.accessToken
  }
}

export default connect(mapStateToProps)(SettingsTextbooks);