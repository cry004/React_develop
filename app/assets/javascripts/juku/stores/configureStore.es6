import { createStore, compose, combineReducers, applyMiddleware } from 'redux'
import adapter from 'redux-localstorage/lib/adapters/localStorage';
import persistState, {mergePersistedState} from 'redux-localstorage';
import { routerReducer } from 'react-router-redux'
import createSagaMiddleware from 'redux-saga';

import requestPrefectures from '../reducers/Prefectures.es6'
import requestRooms from '../reducers/Rooms.es6'
import requestBoxes from '../reducers/Boxes.es6'
import requestAccessToken from '../reducers/AccessToken.es6'
import requestCurriculums from '../reducers/Curriculums.es6'
import requestSimulator from '../reducers/Simulator.es6'
import requestLearnings from '../reducers/Learnings.es6'
import requestLearningReports from '../reducers/Reports.es6'
import requestStudents from '../reducers/Students.es6'
import requestHistories from '../reducers/History.es6'
import requestPdf from '../reducers/Pdf.es6'
import requestNumberOfWeeks from '../reducers/NumberOfWeeks.es6'
import requestErrorMessage from '../reducers/ErrorMessage.es6'
import locationHash from '../reducers/locationHash.es6'
import rootSaga from '../sagas/index.es6';

export default function configureStore() {
  const sagaMiddleware = createSagaMiddleware();
  const rootReducer = combineReducers({
    requestPrefectures,
    requestBoxes,
    requestAccessToken,
    requestRooms,
    requestCurriculums,
    requestLearningReports,
    requestLearnings,
    requestHistories,
    requestPdf,
    requestSimulator,
    requestStudents,
    requestNumberOfWeeks,
    requestErrorMessage,
    locationHash,
    routing: routerReducer
  })
  const reducer = compose(
    mergePersistedState()
  )(rootReducer);
  const storage = compose()(adapter(window.localStorage));
  const enhancer = compose(persistState(storage));
  const store = createStore(
    reducer,
    applyMiddleware(
      sagaMiddleware
    ),
    enhancer
  )
  sagaMiddleware.run(rootSaga);
  return store
}

