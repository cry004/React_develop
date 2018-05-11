import React, { Component } from 'react'
import classNames from 'classnames'
import _ from 'lodash'

import { requestLogout } from '../../../actions/login.es6'

import { updateSearchInput,
  requestSearchWords,
  requestVideoTags,
  postSearchedWord,
  requestSearchVideos,
  updateSearchKeyword,
  updateSearchGrade } from '../../../actions/search.es6'

export class Search extends Component {
  constructor(props) {
    super(props)
    this.state = {
      _isEnteringWord: false
    }
  }
  componentWillMount() {
    const { accessToken, dispatch } = this.props
    dispatch(requestSearchWords(accessToken.accessToken))
    dispatch(requestVideoTags(accessToken.accessToken))
  }
  changeKeyword() {
    const { dispatch } = this.props
    let keyword = this.keywordDom.value
    dispatch(updateSearchInput(keyword))
    this.setState({
      _isEnteringWord: true
    })
  }
  stopPropagation(e) {
    e.stopPropagation();
  }
  searchStudies(e, tag) {
    const { accessToken, dispatch } = this.props
    e.stopPropagation()
    ga('send', 'event', '検索タグをクリック', 'click', 'pc_search_click', 1)
    this.keywordDom.value = tag
    dispatch(requestSearchVideos(accessToken.accessToken, tag, 1))
    dispatch(postSearchedWord(accessToken.accessToken, tag))
    dispatch(updateSearchInput(tag))
    dispatch(updateSearchKeyword(tag))
    dispatch(updateSearchGrade("all"))
    this.setState({
      _isEnteringWord: false
    })
  }
  componentWillUnmount() {
    const { dispatch } = this.props
    dispatch(updateSearchInput(""))
    this.keywordDom.value = ""
  }
  escapeKeyword(keyword) {
    return keyword
      .replace(/[！-～]/g, (word) => { // 半角→全角
        return String.fromCharCode(word.charCodeAt(0) - 0xFEE0)
      })
      .replace(/[\u30a1-\u30f6]/g, (word) => { // カタカナ→ひらがな
        return String.fromCharCode(word.charCodeAt(0) - 0x60)
      })
      .replace(/[A-Z]/g, (word) => { // 大文字→小文字
        return String.fromCharCode(word.charCodeAt(0) | 32)
      })
      .replace(/\+/g, '\\+')
      .replace(/\(/g, '\\(')
      .replace(/\)/g, '\\)')
      .replace(/\[/g, '\\[')
      .replace(/\]/g, '\\]')
      .replace(/\?/g, '\\?')
      .replace(/\^/g, '\\^')
      .replace(/\$/g, '\\$')
  }
  render() {
    const { search } = this.props
    // const regexp = new RegExp(search.input === "" ? '\\s' : search.input)
    const regexp = new RegExp(this.escapeKeyword(search.input))
    let histories = _.filter(search.words, (word, i) => {
      let matches = _.filter(word.values, (value) => {
        return regexp.test(value)
      })
      return matches.length > 0
    })
    // 最大4件表示
    if (histories.length > 4) {
      histories = histories.slice(0, 4)
    }

    let removeTags = search.tags
    histories.forEach((history) => {
      removeTags = _.filter(removeTags, (word) => {
        return word.name !== history.name
      })
    })

    let tags = _.filter(removeTags, (word, i) => {
      let matches = _.filter(word.values, (value) => {
        return regexp.test(value)
      })
      return matches.length > 0
    })
    if (tags.length > (10 - histories.length)) {
      tags = tags.slice(0, 10 - histories.length)
    }
    const candidateClass = classNames('bl-header-keyword-candidate', {'u-hidden': (histories.length === 0  && tags.length === 0 || search.input === "" || this.state._isEnteringWord === false)})
    const inputClass = classNames('bl-header-keyword-input', {'is-active': this.keywordDom && this.keywordDom.value !== "" })
    return (
      <div className="bl-header-keyword" >
        <input className={inputClass} type="text" maxLength="100" placeholder="キーワードを入力 ( 例：不定詞、２次方程式、フレミングの法則... )" ref={(keyword) => this.keywordDom = keyword} onChange={() => this.changeKeyword()} onClick={(e) => this.stopPropagation(e)} />
        <ul className={candidateClass}>
          {histories.map((word, i) => {
            return (
              <li className="icon-history" key={i} onClick={(e) => this.searchStudies(e, word.name)}>
                {word.name}
              </li>
            )}
          )}
          {tags.map((tag, i) => {
            return (
              <li key={i} onClick={(e) => this.searchStudies(e, tag.name)}>
                {tag.name}
              </li>
            )}
          )}
        </ul>
      </div>
    )
  }
}