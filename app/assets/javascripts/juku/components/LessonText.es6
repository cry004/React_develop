import React, { Component } from 'react'
import classNames from 'classnames'

export class LessonText extends Component {

  constructor(props) {
    super(props)
  }

  render() {
    const { video } = this.props
    let lesson_text_url = video.lesson_text_url
    let lesson_text_answer_url = video.lesson_text_answer_url
    let lessonTextDom
    
    if(lesson_text_url != '' && lesson_text_url != null && lesson_text_answer_url != '' && lesson_text_answer_url != null) {
      lessonTextDom = <div>
          <h5 className="title print">授業テキスト</h5>
          <a href={lesson_text_url} target="_blank" className="el-button size-mini">問題</a>
          <a href={lesson_text_answer_url} target="_blank" className="el-button size-mini">解答</a>
        </div>
    }
    
    let containerClass = classNames({'btns-area': (lesson_text_url && lesson_text_answer_url)})
    
    return (
      <div className={containerClass}>
        {lessonTextDom}
      </div>
    )
  }
}