import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import { HashRouter, Route, IndexRoute } from 'react-router-dom'

import configureStore from '../stores/configureStore.es6'

import Home from '../components/Home.es6'

// Add the reducer to your store on the `routing` key
const store = configureStore()

// Create an enhanced history that syncs navigation events with the store

ReactDOM.render(
  <Provider store={store}>
    <HashRouter>
      <Home />
    </HashRouter>
  </Provider>,
  document.getElementById('root')
)
