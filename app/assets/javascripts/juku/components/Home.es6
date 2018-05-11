import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Route, Switch, Redirect } from 'react-router-dom'

// block
import { Header } from '../components/Header.es6'
import { Footer } from '../components/Footer.es6'
import { ErrorMessage } from '../components/ErrorMessage.es6'

// page
import App from '../components/App.es6'
import Schedule from '../components/Schedule.es6'
import RoomSelect from '../components/RoomSelect.es6'
import StudentDetail from '../components/StudentDetail.es6'
import Students from '../components/Students/index.es6'
import CurriculumEdit from '../components/CurriculumEdit.es6'
import StudentHistory from '../components/StudentHistory.es6'
import Report from '../components/Report.es6'
import Simulator from '../components/Simulator/index.es6'

import { updateLocationHash } from '../actions/locationHash.es6'
import { isFromTryPlus, initFromTryPlus } from '../actions/AccessToken.es6'

class Home extends Component {

  constructor(props) {
    super(props)
  }
  componentWillMount() {
    const { dispatch } = this.props
    dispatch(updateLocationHash(window.location.hash.substr(1)))
    let classroomId = this.getQueryVariable("classroom_id")
    let classroomName = this.getQueryVariable("classroom_name")

    if( classroomId && classroomName ) {
      dispatch(isFromTryPlus())
    }
    window.addEventListener('hashchange', (e) => {
      dispatch(updateLocationHash(window.location.hash.substr(1)))
      classroomId = this.getQueryVariable("classroom_id")
      classroomName = this.getQueryVariable("classroom_name")
      if( classroomId && classroomName ) {
        dispatch(isFromTryPlus())
      } else {
        dispatch(initFromTryPlus())
      }
    })
  }

  getQueryVariable(keyName){
     const query = window.location.search.substring(1)
     const vars = query.split("&")
     for (let i = 0; i < vars.length; i++) {
       const pair = vars[i].split("=")
       if(pair[0] === keyName){return pair[1] }
     }
     return(false)
   }

  render() {
    const { errors, dispatch, isFromTryPlus } = this.props
    return (
      <div className="app">
        <Header />
        <Switch>
          <Route exact path="/" component={App} />
          <TryplusRoute path="/room" component={RoomSelect} isFromTryPlus={isFromTryPlus}/>
          <Route exact path="/schedule" component={Schedule} />
          <Route exact path="/student" component={StudentDetail} />
          <Route exact path="/students" component={Students} />
          <Route exact path="/edit" component={CurriculumEdit} />
          <Route exact path="/simulator" component={Simulator} />
          <Route exact path="/history" component={StudentHistory} />
          <Route exact path="/report" component={Report} />
        </Switch>
        <Footer />
        <ErrorMessage errors={errors} dispatch={dispatch} />
      </div>
    )
  }
}

const TryplusRoute = ({ component: Component, ...rest }) => {
  return <Route　{...rest} render={(props) => {
    if({...rest}.isFromTryPlus) {
      return  <Redirect to="/schedule"/>
    } else {
      return  <Component {...props}/>
    }
  }} />
}

const mapStateToProps = (state) => {
  return {
    errors: state.requestErrorMessage.errors,
    isFromTryPlus: state.requestAccessToken.isFromTryPlus,
    locationHash: state.locationHash //locationHashが変わったらrenderを走らせたいため
  }
}

export default connect(mapStateToProps)(Home);
