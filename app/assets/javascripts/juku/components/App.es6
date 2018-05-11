import React, { Component } from 'react'
import { connect } from 'react-redux'

import { setAccessToken } from '../actions/AccessToken.es6'
import { selectedRoom, setErrorMessageFlag } from '../actions/Rooms.es6'

class App extends Component {

  constructor(props) {
    super(props)
    this.movedToRoom = false
    this.movedToSchedule = false
  }

  componentWillMount() {
    const { dispatch } = this.props
    const arg = new Object
    let pair = location.search.substring(1).split('&')
    for(let i = 0; pair[i]; i++) {
      let kv = pair[i].split('=');
      arg[kv[0]] = kv[1];
    }
    dispatch(setAccessToken(arg.token))
  }

  getQueryVariable(keyName){
     const query = window.location.search.substring(1)
     const vars = query.split("&")
     for (let i = 0; i < vars.length; i++) {
       const pair = vars[i].split("=")
       if(pair[0] == keyName){return pair[1] }
     }
     return(false)
   }

  componentWillReceiveProps(nextProps) {
    const { isAccessToken, dispatch } = nextProps
    const classroomId = this.getQueryVariable("classroom_id")
    const classroomName = this.getQueryVariable("classroom_name")

    if(isAccessToken) {
      if( classroomId && classroomName && !this.movedToSchedule) {
        this.movedToSchedule = true
        dispatch(selectedRoom(classroomId, decodeURIComponent(classroomName).split('+').join(' ')))
        dispatch(setErrorMessageFlag(false))
        window.location.hash = '/schedule'
      }else if(!this.movedToRoom){
        this.movedToRoom = true
        window.location.hash = '/room'
      }
    }
  }

  render() {
    return (
      <div></div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    access_token: state.requestAccessToken.access_token,
    isAccessToken: state.requestAccessToken.isAccessToken
  }
}

export default connect(mapStateToProps)(App);
