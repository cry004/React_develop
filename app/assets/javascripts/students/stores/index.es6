import { createStore, compose, combineReducers, applyMiddleware } from 'redux'
import adapter from 'redux-localstorage/lib/adapters/localStorage';
import persistState, {mergePersistedState} from 'redux-localstorage';
import createSagaMiddleware from 'redux-saga';
import rootSaga from '../sagas/index.es6';

import video from '../reducers/video.es6'
import videos from '../reducers/videos.es6'
import createQuestion from '../reducers/createQuestion.es6'
import question from '../reducers/question.es6'
import learningProgresses from '../reducers/learningProgresses.es6'
import login from '../reducers/login.es6'
import user from '../reducers/user.es6'
import courses from '../reducers/courses.es6'
import search from '../reducers/search.es6'
import notifications from '../reducers/notifications.es6'
import bookmark from '../reducers/bookmark.es6'
import history from '../reducers/history.es6'
import popup from '../reducers/popup.es6'
import questions from '../reducers/questions.es6'
import teacher from '../reducers/teacher.es6'
import jukuLearnings from '../reducers/jukuLearnings.es6'
import ranking from '../reducers/ranking.es6'
import rankingClassroom from '../reducers/rankingClassroom.es6'
import scroll from '../reducers/scroll.es6'
import accessToken from '../reducers/accessToken.es6'
import pager from '../reducers/pager.es6'
import news from '../reducers/news.es6'
import locationHash from '../reducers/locationHash.es6'
import workbooks from '../reducers/workbooks.es6'
import alerts from '../reducers/alerts.es6'
import level from '../reducers/level.es6'
import loading from '../reducers/loading.es6'

//util
import useragent from '../reducers/useragent.es6'
import hostname from '../reducers/hostname.es6'

export default function configureStore() {
  const sagaMiddleware = createSagaMiddleware();
  const rootReducer = combineReducers({
    video,
    videos,
    useragent,
    createQuestion,
    question,
    learningProgresses,
    login,
    user,
    courses,
    search,
    notifications,
    bookmark,
    history,
    popup,
    questions,
    teacher,
    jukuLearnings,
    ranking,
    rankingClassroom,
    scroll,
    accessToken,
    pager,
    news,
    locationHash,
    workbooks,
    alerts,
    level,
    loading,
    hostname
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

