import React, { Component } from 'react'
import classNames from 'classnames'

import { hideExperience } from '../../../actions/level.es6' 
 
export class Experience extends Component {
  constructor(props) {
    super(props)
  }
  componentDidMount() {
    const { dispatch } = this.props
    setTimeout(function() {
      dispatch(hideExperience())
    }, 4000)
  }

  componentWillReceiveProps(nextProps) {
    const { dispatch } = this.props
    if (nextProps.level.experienceIsShow === true) {
      setTimeout(function() {
        dispatch(hideExperience())
      }, 4000)
    }
  }

  closeExperience() {
    const { dispatch } = this.props
    dispatch(hideExperience())
  }
  render() {
    const { level } = this.props
    const experienceClass = classNames('el-experience', {'is-visible': level.experienceIsShow === true })
    return(
      <div className={experienceClass}>
        <a className="el-experience-close" onClick={()=> this.closeExperience()}>
        </a>
        <p className="el-experience-text">
          <span className="el-experience-text-label">経験値</span>
          + {level.experience}
        </p>
      </div>
    )
  }
}