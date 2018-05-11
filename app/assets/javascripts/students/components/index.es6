import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import { HashRouter } from 'react-router-dom'
import configureStore from '../stores/index.es6'

import Home from '../components/Home.es6'

const store = configureStore()
ReactDOM.render(
  <Provider store={store}>
    <HashRouter>
      <Home />
    </HashRouter>
  </Provider>,
  document.getElementById('root')
)
