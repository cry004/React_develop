import React, { Component } from 'react'
import { setSearchText, searchStudents } from '../../actions/Students.es6'

export class Search extends Component {

  constructor(props) {
    super(props)
  }

  changeText(e) {
    const { dispatch } = this.props
    dispatch(setSearchText(e.target.value))
    this.searchName(e.target.value)
  }

  searchName(text) {
    const { dispatch, students } = this.props
    let result = []
    if (text.match(/^[\u3040-\u309F]+$/)) {　//全てひらがな入力の時
      let word = this.hiraganaToKatagana(text)
      students.forEach(function (student) {
        let studentName = student.student_name_kana.replace(/\s+/g, "")
        if ( studentName.indexOf(word) != -1) {
          result.push(student)
        }
      });
    } else if (text.match(/^[\u30A0-\u30FF]+$/)) {　//全て全角カナ入力の時
      students.forEach(function (student) {
        let studentName = student.student_name_kana.replace(/\s+/g, "")
        if ( studentName.indexOf(text) != -1) {
          result.push(student)
        }
      });
    } else {
      students.forEach(function (student) {
        let studentName = student.student_name.replace(/\s+/g, "")
        if ( studentName.indexOf(text) != -1) {
          result.push(student)
        }  
      });
    }
    dispatch(searchStudents(result))
  }

  hiraganaToKatagana(text) {
    return text.replace(/[\u3041-\u3096]/g, function(match) {
        var chr = match.charCodeAt(0) + 0x60;
        return String.fromCharCode(chr);
    });
  }

  render() {
    const { search_text } = this.props
    return (
      <div>
        <input className="search" type="text" value={search_text} maxLength={"100"} onChange={this.changeText.bind(this)} placeholder="生徒名検索" />
      </div>
    )
  }
}