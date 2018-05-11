import "babel-polyfill" // need to use promise
import { takeEvery } from 'redux-saga'
import { take, put, call, fork, select } from 'redux-saga/effects'

import ApiClient from '../util/apiClient.es6'

import { REQUEST_LOGIN,
  loginErrorMessage,
  REQUEST_LOGOUT } from '../actions/login.es6'

import { UPDATE_NICKNAME,
  UPDATE_AVATAR,
  REQUEST_USER,
  receiveNickname,
  updateNicknameError,
  updateNicknameSuccess,
  receiveUser,
  HIDE_SCHOOLBOOK_DIALOGS,
  REQUEST_USER_PRIVACY_SETTINGS,
  receivePrivateFlag,
  UPDATE_PRIVATE_FLAG,
  REQUEST_SCHOOLBOOKS,
  receiveSchoolbooks,
  receiveSchoolbooksUpdate,
  changeNotificationsCount,
  UPDATE_SCHOOLBOOKS_SETTING,
  receiveFirstLogin } from '../actions/user.es6'

import { REQUEST_SEARCH_WORDS,
  receiveSearchWords,
  POST_SEARCHED_WORD,
  REQUEST_VIDEO_TAGS,
  receiveVideoTags,
  REQUEST_SEARCH_VIDEOS,
  receiveSearchVideos,
  REQUEST_SEARCH_UNITS,
  receiveSearchUnits
} from '../actions/search.es6'

import { REQUEST_VIDEO,
  REQUEST_VIDEO_DETAIL,
  POST_PLAY_TIME,
  receiveVideo,
  ADD_BOOKMARK,
  DELETE_BOOKMARK_VIDEO,
  receiveBookmark,
  updateVideoCurrentTab,
  PLAY_AND_POSITION_BAR_CLICK } from '../actions/video.es6'

import { REQUEST_VIDEOS,
  receiveVideos,
  UPDATE_CURRENT_COURCE,
  updateFilteredUnits } from '../actions/videos.es6'

import { REQUEST_BOOKMARKS,
  receiveBookmarks,
  DELETE_BOOKMARK,
  deletedBookmark } from '../actions/bookmark.es6'

import { REQUEST_QUESTIONS,
  DELETE_QUESTION,
  receiveQuestions,
  deletedQuestion } from '../actions/questions.es6'

import { REQUEST_QUESTION,
  receiveQuestion,
  UPDATE_QUESTION_READ,
  RESOLVE_QUESTION,
  UNRESOLVE_QUESTION,
  updateQuestionState
} from '../actions/question.es6'

import { CREATE_QUESTION,
  CREATE_QUESTION_BY_VIDEO,
  receiveCreateQuestion,
  UPDATE_QUESTION,
  UPDATE_QUESTION_BY_VIDEO,
  SEND_POINT_REQUEST,
  REQUEST_QUESTION_DRAFT,
  receiveDraft,
  updateCreateQuestionSending,
  updateCreateQuestionStatus,
  CALL_CREATE_QUESTION,
  CALL_CREATE_QUESTION_BY_VIDEO,
  createQuestionErrorMessage,
  CALL_UPDATE_QUESTION,
  CALL_UPDATE_QUESTION_BY_VIDEO } from '../actions/createQuestion.es6'

import { setAccessToken } from '../actions/accessToken.es6'

import { updateCurrentPage, isLastPage } from '../actions/pager.es6'

import { shotePopup, hidePopup } from '../actions/popup.es6'

import { REQUEST_WORKBOOKS,
  receiveWorkbooks } from '../actions/workbooks.es6'

import { REQUEST_TEACHER_RECOMMENDS,
  REQUEST_TEACHER_DETAIL,
  receiveTeacherRecommends,
  receiveTeacherDetail,
  updateCurrentTeacherId,
  readTeacherDetail,
  receiveReadTeacherDetail,
  READ_TEACHER_DETAIL } from '../actions/teacher.es6'

import { REQUEST_HISTORIES,
  receiveHistories,
  DELETE_HISTORY } from '../actions/history.es6'

import { REQUEST_NEWS,
  receiveNews,
  REQUEST_NEWS_DETAIL,
  receiveNewsDetail,
  currentNewsId,
  readNews,
  READ_NEWS,
  receiveReadNews } from '../actions/news.es6'

import { REQUEST_NOTIFICATIONS,
  receiveNotifications,
  receiveReadNotification } from '../actions/notifications.es6'

import { REQUEST_RANKINGS_PERSONAL,
  REQUEST_RANKINGS_PERSONALS,
  receiveRankingsPersonal,
  receiveRankingsPersonals,
  requestRankingsPersonal,
  updateCurrentRankingTab } from '../actions/rankings.es6'

import { REQUEST_RANKINGS_CLASSROOM,
  receiveRankingsClassroom,
  REQUEST_RANKINGS_CLASSROOMS,
  receiveRankingsClassrooms,
  updateCurrentRankingClassroomTab,
  requestRankingsClassroom
} from '../actions/rankingsClassroom.es6'

import { updateAlerts } from '../actions/alerts.es6'

import { REQUEST_LEARNING_PROGRESSES,
  receiveLearningProgresses } from '../actions/learningProgresses.es6'

import { REQUEST_COURSES,
  receiveCourses } from '../actions/courses.es6'

import { REQUEST_JUKU_LEARNINGS_CURRENT,
  REQUEST_JUKU_LEARNINGS_ARCHIVES,
  receiveJukuLearnings } from '../actions/jukuLearnings.es6'

import { showPopup } from '../actions/popup.es6'

import { showExperience } from '../actions/level.es6'

// ==========================
// # login
// ==========================
function* postLogin(login) {
  try {
    const res = yield call(ApiClient.postLoginApi, login)
    if (res.meta.code === 201) {
      yield put(setAccessToken('Bearer ' + res.meta.access_token))
    } else {
      yield put(loginErrorMessage(res.meta.error_messages[0]))
    }
  }
  catch (error) {
    yield put(loginErrorMessage(error.meta.error_messages))
  }
}

function* logout(args) {
  try {
    const res = yield call(ApiClient.logoutApi, args)
    if (res.ok === true) {
      window.location.hash = '/login'
    } else {
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # user
// ==========================
function* fetchUser(args) {
  try {
    const res = yield call(ApiClient.fetchUserApi, args)
    if (res.meta.code === 200) {
      if (!!res.data.nick_name === false) {
        window.location.hash = '/nickname'
      } else if (res.data.avatar === undefined || res.data.avatar === null) {
        window.location.hash = '/avatar'
      } else {
        yield put(receiveUser(res.data))
      }
    } else {
      console.log("error")
    }
  }
  catch(error) {
    if (error.meta) {
      if (error.meta.code === 401) {
        location.hash = '/login'
        return false
      }
    }
    yield put(updateNicknameError(error.meta.error_messages))
  }
}

function* postNickname(args) {
  try {
    const res = yield call(ApiClient.postUserApi, args)
    if (res === true) {
      yield put(receiveNickname(args.nickName))
      if (args.currentPath === '/nickname') {
        window.location.hash = '/avatar'
      } else {
        yield put(updateNicknameSuccess("設定を保存しました"))
      }
    }
  }
  catch (error) {
    if (error.meta) {
      if (error.meta.code === 401) {
        location.hash = '/login'
        return false
      }
    }
    yield put(updateNicknameError(error.meta.error_messages))
  }
}

function* postAvatar(args) {
  try {
    const res = yield call(ApiClient.postUserApi, args)
    if (res === true) {
      window.location.hash = args.nextPath
    } else {
      console.log("error")
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* requestSchoolbooks(args) {
  try {
    const res = yield call(ApiClient.requestSchoolbooksApi, args)
    if (res.meta.code === 200) {
      yield put(receiveSchoolbooks(res.data))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* updateSchoolbooks(args) {
  try {
    const res = yield call(ApiClient.updateSchoolbooksApi, args)
    if (res.meta.code === 201) {
      yield put(receiveSchoolbooksUpdate(args.selectSubject, args.bookname))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


function* putSchoolbookDialogs(args) {
  try {
    const res = yield call(ApiClient.putSchoolbookDialogsApi, args)
    if (res === true) {
      yield put(receiveFirstLogin(false))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* fetchPrivacySettings(args) {
  try {
    const res = yield call(ApiClient.fetchPrivacySettingsApi, args)
    if (res.meta.code === 200) {
      yield put(receivePrivateFlag(res.data.private_flag))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* updatePrivateFlag(args) {
  try {
    const res = yield call(ApiClient.updatePrivateFlagApi, args)
    if (res === true) {
      yield put(receivePrivateFlag(args.privateFlag))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

// ==========================
// # search
// ==========================
function* fetchSearchWords(args) {
  try {
    const res = yield call(ApiClient.fetchSearchWordsApi, args)
    if (res.meta.code === 200) {
      yield put(receiveSearchWords(res.data.words))
    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* postSearchedWord(args) {
  try {
    const res = yield call(ApiClient.postSearchedWordApi, args)
    window.location.hash = '/search'
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* fetchVideoTags(args) {
  try {
    const res = yield call(ApiClient.fetchVideoTagsApi, args)
    if (res.meta.code === 200) {
      yield put(receiveVideoTags(res.data.tags))
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* fetchSearchVideos(args) {
  try {
    const res = yield call(ApiClient.fetchSearchVideosApi, args)
    if (res.meta.code === 200) {
      const state = yield select()
      const data = res.data
      const videos = args.page === 1  ? data.videos : state.search.videos.concat(data.videos)
      yield put(receiveSearchVideos(data.units_count, data.units, data.videos_count, videos))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(data.videos.length < args.perPage))
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* fetchSearchUnits(args) {
  try {
    const res = yield call(ApiClient.fetchSearchUnitsApi, args)
    if (res.meta.code === 200) {
      yield put(receiveSearchUnits(res.data))
    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}


// ==========================
// # video
// ==========================
function* fetchVideo(args) {
  try {
    const res = yield call(ApiClient.fetchVideoApi, args)
    if (res.meta.code === 200) {
      window.location.hash = '/video'
      yield put(receiveVideo(res.data))
      if (res.data.kaisetu_web_url) {
        yield put(updateVideoCurrentTab('commentary'))
      } else if (res.data.lessontext_url) {
        //テキストがnullの時は「前後の授業」(videos)タブをactiveにする
        yield put(updateVideoCurrentTab('textbook'))
      } else {
        yield put(updateVideoCurrentTab('videos'))
      }
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* postVideoWatched(args) {
  try {
    const res = yield call(ApiClient.postVideoWatchedApi, args)
    if (res.meta.code === 201) {
      if (res.data.schoolbook_trophy_flag === true || res.data.unit_trophy_flag === true) {
        yield put(showPopup('trophy', {
          subjectKey: res.data.title.subject_key,
          schoolName: res.data.title.school_name,
          subjectName: res.data.title.subject_name,
          subjectType: res.data.title.subject_type,
          subjectDetailName: res.data.title.subject_detail_name,
          isCourseComplete: !!res.data.schoolbook_trophy_flag,
          unitName: res.data.unit_name,
          level: res.data.level,
          levelUpFlag: res.data.level_up_flag,
          trophiesProgress: res.trophies_progress
        }))
      } else if (res.data.level_up_flag === true) {
        yield put(showPopup('level', {
          level: res.data.level
        }))
      }
      if (res.data.experience_point > 0) {
        yield put(showExperience(res.data.experience_point))
      }
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* fetchVideoDetail(args) {
  try {
    const res = yield call(ApiClient.fetchVideoDetailApi, args)
    if (res === true) {

    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* addBookmark(args) {
  try {
    const res = yield call(ApiClient.postBookmarkApi, args)
    if (res === true) {
      yield put(receiveBookmark(true))
    }
    //
    //}
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* deleteBookmarkVideo(args) {
  try {
    const res = yield call(ApiClient.deleteBookmarkApi, args)
    if (res.statusCode === 204) {
      yield put(receiveBookmark(false))
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* deleteBookmark(args) {
  try {
    const res = yield call(ApiClient.deleteBookmarkApi, args)
    if (res.statusCode === 204) {
      yield put(deletedBookmark(args.videoId))
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
function* fetchBookmarks(args) {
  try {
    const res = yield call(ApiClient.fetchBookmarksApi, args)
    if (res.meta.code === 200) {
      yield put(receiveBookmarks(res.data.videos))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.videos.length < args.perPage))
    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}
//トライさん側での計測に必要なので削除しないこと
function* postPlayAndPositionBarClick(args) {
  try {
    yield call(ApiClient.postPlayAndPositionBarClickApi, args)
  }
  catch(error) {
    showErrorMessage(error)
  }
}


// ==========================
// # questions
// ==========================
function* fetchQuestions(args) {
  try {
    const res = yield call(ApiClient.fetchQuestionsApi, args)
    if (res.meta.code === 200) {
      yield put(receiveQuestions(res.data.questions))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.questions.length < args.perPage))
    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* deleteQuestions(args) {
  try {
    const status = yield call(ApiClient.deleteQuestionsApi, args)
    if(status === 204) {
      yield put(deletedQuestion(args.deleteId))
      yield put(hidePopup())
    } else {
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* fetchQuestion(args) {
  try {
    const res = yield call(ApiClient.fetchQuestionApi, args)
    if (res.meta.code === 200) {
      yield put(receiveQuestion(res.data))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* updateQuestionRead(args) {
  try {
    const res = yield call(ApiClient.updateQuestionReadApi, args)
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* createQuestion(args) {
  try {
    const checkIsVacation = yield call(fetchIsVacation, args)
    if (checkIsVacation.isVacation === true) {
      yield put(showPopup('vacation', {
        popupType: 'noVideo',
        messages: checkIsVacation.messages || []
      }))
      return false
    }
    yield call(callCreateQuestion, args)
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* callCreateQuestion(args) {
  try {
    const res = yield call(ApiClient.createQuestionApi, args)
    if (res.meta.code === 201) {
      yield put(receiveCreateQuestion(res.data))
      location.hash = '/create_question'
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* createQuestionByVideo(args) {
  try {
    const state = yield select()
    const checkIsVacation = yield call(fetchIsVacation, args)
    if (checkIsVacation.isVacation === true) {
      yield put(showPopup('vacation', {
        popupType: 'withVideo',
        videoId: state.video.id,
        position: parseInt(state.video.currentTime, 10),
        messages: checkIsVacation.messages || []
      }))
      return false
    }
    yield call(callCreateQuestionByVideo, args)
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* callCreateQuestionByVideo(args) {
  try {
    const res = yield call(ApiClient.createQuestionByVideoApi, args)
    if(res.meta.code === 201) {
      yield put(receiveCreateQuestion(res.data))
      location.hash = '/create_question'
    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* updateQuestion(args) {
  try {
    // submit
    if (args.createFlag === true) {

      const state = yield select()
      // check for point shortage
      if (state.user.availablePoint < state.user.questionPoint) {
        yield put(showPopup('requestpoint', {
          isNewUser: state.user.isNewUser
        }))
        return false
      }

      // form validation
      if (!state.createQuestion.selectedSubject) {
        yield put(createQuestionErrorMessage(["科目を選択してください"]))
        return false
      }
      else if (state.createQuestion.imageFile === null && state.createQuestion.resourceUrl === null) {
        yield put(createQuestionErrorMessage(["画像をアップロードしてください"]))
        return false
      } else if (state.createQuestion.text === "") {
        yield put(createQuestionErrorMessage(["質問内容を入力してください"]))
        return false
      }

      // confirm popup
      yield put(showPopup('submit-question', {
        popupType: 'noVideo',
        questionId: state.createQuestion.questionId,
        createFlag: true,
        withoutVideo: {
          upload_file: state.createQuestion.imageFile,
          body: state.createQuestion.text,
          course_name: state.createQuestion.selectedSubject
        }
      }))
    
    // draft
    } else {
      yield fork(callUpdateQuestion, args)
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* callUpdateQuestion(args) {
  try {
    const res = yield call(ApiClient.updateQuestionApi, args)
    if (res.meta.code === 201) {
      yield put(updateCreateQuestionSending(false))
      if (args.createFlag === true) {
        yield put(showPopup('post-question'))
      } else {
        yield put(showPopup('post-question-draft'))
      }
    }
  }
  catch (error) {
    if (!!error.meta) {
      yield put(showPopup('not-accept-question', {
        messages: error.meta.error_messages || []
      }))
      return false
    }
    showErrorMessage(error)
  }
}

function* updateQuestionByVideo(args) {
  try {

    // submit
    if (args.createFlag === true) {
      
      const state = yield select()
      // check for point shortage
      if (state.user.availablePoint < state.user.questionPoint) {
        yield put(showPopup('requestpoint', {
          isNewUser: state.user.isNewUser
        }))
        return false
      }

      // form validation
      if (state.createQuestion.text === "") {
        yield put(createQuestionErrorMessage(["質問内容を入力してください"]))
        return false
      }

      // confirm popup
      yield put(showPopup('submit-question', {
        popupType: 'withVideo',
        questionId: args.questionId,
        createFlag: args.createFlag,
        withVideo: args.withVideo
      }))

    // draft
    } else {
      yield fork(callUpdateQuestionByVideo, args)
    }
  }
  catch (error) {
    showErrorMessage(error)
    yield put(hidePopup())
  }
}

function* callUpdateQuestionByVideo(args) {
  try {
    const res = yield call(ApiClient.updateQuestionByVideoApi, args)
    if(res.meta.code === 201) {
      yield put(updateCreateQuestionSending(false))
      if (args.createFlag === true) {
        yield put(showPopup('post-question'))
      } else {
        yield put(showPopup('post-question-draft'))
      }
    }
  }
  catch (error) {
    if (!!error.meta) {
      yield put(showPopup('not-accept-question', {
        messages: error.meta.error_messages || []
      }))
      return false
    }
    showErrorMessage(error)
    yield put(hidePopup())
  }
}

function* fetchIsVacation(args) {
  try {
    const res = yield call(ApiClient.fetchVacationApi, args)
    if(res.meta.code === 200) {
      return {
        isVacation: false
      }
    }
  }
  catch(error) {
    if (error.meta.code === 400) {
      return {
        isVacation: true,
        messages: error.meta.error_messages
      }
    } else {
      showErrorMessage(error)  
    }
  }
}

function* fetchQuestionDraft(args) {
  try {
    const res = yield call(ApiClient.fetchQuestionDraftApi, args)
    if(res.meta.code === 200) {
      yield put(receiveDraft(res.data))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* resolveQuestion(args) {
  try {
    const res = yield call(ApiClient.resolveQuestionApi, args)
    if (res === true) {
      yield put(updateQuestionState({
        key: 'resolved',
        name: '解決済み'
      }))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* unresolveQuestion(args) {
  try {
    const res = yield call(ApiClient.unresolveQuestionApi, args)
    if (res === true) {
      yield put(updateQuestionState({
        key: 'answered',
        name: '返信あり'
      }))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

// ==========================
// # workbooks
// ==========================
function* fetchWorkbooks(args) {
  try {
    const res = yield call(ApiClient.fetchWorkbooksApi, args)
    if(res.meta.code === 200) {
     yield put(receiveWorkbooks(res.data.subjects))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # teacher
// ==========================
function* fetchTeacherRecommends(args) {
  try {
    const res = yield call(ApiClient.fetchTeacherRecommendsApi, args)
    if (res.meta.code === 200) {
      yield put(receiveTeacherRecommends(res.data.recommendations))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.recommendations.length < args.perPage))
      if (args.isUpdateCurrentId === true && res.data.recommendations.length > 0) {
        yield put(updateCurrentTeacherId(res.data.recommendations[0].recommendation_id))
      }
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function* fetchTeacherDetail(args) {
  try {
    const res = yield call(ApiClient.fetchTeacherDetailApi, args)
    if (res.meta.code === 200) {
      yield put(receiveTeacherDetail(res.data))
      yield put(readTeacherDetail(args.accessToken, args.id))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* updateReadTeacherDetail(args) {
  try {
    const res = yield call(ApiClient.updateReadTeacherDetailApi, args)
    if (res === true) {
      yield put(receiveReadTeacherDetail(args.id))
      yield put(receiveReadNotification(args.id, 'teacher_recommendation'))
      yield put(changeNotificationsCount())
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

// ==========================
// # history
// ==========================
function* fetchHistories(args) {
  try {
    const res = yield call(ApiClient.fetchHistoriesApi, args)
    if (res.meta.code === 200) {
      yield put(receiveHistories(res.data.videos))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.videos.length < args.perPage))
    } else {

    }
  }
  catch(error) {
    showErrorMessage(error)
  }
}

function* deleteHistory(args) {
  try {
    const res = yield call(ApiClient.deleteHistoryApi, args)
    //if (res.meta.code === 200) {
    //  yield put(receiveHistories(res.data.videos))
    //  yield put(updateCurrentPage(args.page))
    //  yield put(isLastPage(res.data.videos.length < args.perPage))
    //} else {
    //
    //}
  }
  catch(error) {
    showErrorMessage(error)
  }
}


// ==========================
// # news
// ==========================
function* fetchNews(args) {
  try {
    const res = yield call(ApiClient.fetchNewsApi, args)
    if(res.meta.code === 200) {
      yield put(receiveNews(res.data.news))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.news.length < args.perPage))
      if (args.isUpdateCurrentId === true && res.data.news.length > 0) {
        yield put(currentNewsId(res.data.news[0].id))
      }
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* fetchNewsDetail(args) {
  try {
    const res = yield call(ApiClient.fetchNewsDetailApi, args)
    if (res.meta.code === 200) {
      yield put(receiveNewsDetail(res.data))
      yield put(readNews(args.accessToken, res.data.id))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* updateReadNews(args) {
  try {
    const res = yield call(ApiClient.updateReadNewsApi, args)
    if (res === true) {
      yield put(receiveReadNews(args.id))
      yield put(receiveReadNotification(args.id, 'news'))
      yield put(changeNotificationsCount())
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}



// ==========================
// # notifications
// ==========================
function* fetchNotifications(args) {
  try {
    const res = yield call(ApiClient.fetchNotificationsApi, args)
    if(res.meta.code === 200) {
      yield put(receiveNotifications(res.data.notifications))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # rankings
// ==========================
function* fetchRankingsPersonal(args) {
  try {
    const res = yield call(ApiClient.fetchRankingsPersonalApi, args)
    if(res.meta.code === 200) {
      yield put(receiveRankingsPersonal(res.data))
      const gaPeriodType = args.term === 'last_7_days' ? 'week' : 'month'
      let gaRegionType = args.region
      if (args.region === 'prefecture') {
        gaRegionType = 'prefectures'
      } else if (args.region === 'national') {
        gaRegionType = 'all'
      }
      ga('send', 'event', 'ランキングページ', 'view', `pc_ranking_${gaPeriodType}_invisible_${gaRegionType}`, 1)
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* fetchRankingsPersonals(args) {
  try {
    const res = yield call(ApiClient.fetchRankingsPersonalsApi, args)
    if(res.meta.code === 200) {
      yield put(receiveRankingsPersonals(res.data))
      const periodTypes = window.location.hash.match(/period_type=(.*?)(&|$)/)
      const periodType = periodTypes.length > 0 ? periodTypes[1] : 'last_7_days'
      const student = res.data.student
      let rankingType = ""
      if (student.classroom_type === "classroom" || student.classroom_type === "schoolhouse") {
        rankingType = student.classroom_type
      } else if (student.school_address) {
        rankingType = "prefecture"
      } else {
        rankingType = "national"
      }
      yield put(requestRankingsPersonal(args.accessToken, rankingType, periodType))
      yield put(updateCurrentRankingTab(rankingType))
    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* fetchRankingsClassroom(args) {
  try {
    const res = yield call(ApiClient.fetchRankingsClassroomApi, args)
    if(res.meta.code === 200) {
      yield put(receiveRankingsClassroom(res.data))
      const gaPeriodType = args.term === 'last_7_days' ? 'week' : 'month'
      const gaRegionType = args.region === 'national' ? 'all' : args.region
      ga('send', 'event', 'ランキングページ', 'view', `pc_ranking_${gaPeriodType}_class_${args.classroomType}_${gaRegionType}`, 1)
    }
  }
  catch (error) {
    if (error.meta.code === 401) {
      location.hash = '/login'
      return false
    }
    yield put(updateAlerts(error.meta.error_messages))
  }
}
function* fetchRankingsClassrooms(args) {
  try {
    const res = yield call(ApiClient.fetchRankingsClassroomsApi, args)
    if(res.meta.code === 200) {
      yield put(receiveRankingsClassrooms(res.data))
      const periodTypes = window.location.hash.match(/period_type=(.*?)(&|$)/)
      const periodType = periodTypes.length > 0 ? periodTypes[1] : 'last_7_days'
      const classroomType = res.data.classroom.type === 'schoolhouse' ? 'schoolhouse' : 'classroom'
      const regionType = res.data.classroom.type === 'classroom' ? 'prefecture' : 'national'
      yield put(requestRankingsClassroom(args.accessToken, regionType, periodType, classroomType))
      yield put(updateCurrentRankingClassroomTab({
        classroomType: classroomType,
        regionType: regionType
      }))
    }
  }
  catch (error) {
    if (error.meta.code === 401) {
      location.hash = '/login'
      return false
    }
    yield put(updateAlerts(error.meta.error_messages))
  }
}



// ==========================
// # point request
// ==========================
function* sendPointRequest(args) {
  try {
    const res = yield call(ApiClient.sendPointRequestApi, args)
    if (res === true) {
      yield put(showPopup('complete-request-point'))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # LearningProgresses
// ==========================
function* fetchLearningProgresses(args) {
  try {
    const res = yield call(ApiClient.fetchLearningProgressesApi, args)
    if(res.meta.code === 200) {
      let lastLearning = res.data.last_learning_subjects
      const sugests = yield lastLearning.map((learning, i) => {
         return call(ApiClient.fetchVideosApi, {
          accessToken: args.accessToken,
          year: learning.schoolyear === "c" ? "c1" : learning.schoolyear,
          subject: learning.subject_name_and_type
        })
      })
      lastLearning.map((learning, i) => {
        res.data.last_learning_subjects[i].videos_suggest = sugests[i].data.videos_suggest
      })
      yield put(receiveLearningProgresses(res.data))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

// ==========================
// # videos
// ==========================
function* fetchVideos(args) {
  try {
    const res = yield call(ApiClient.fetchVideosApi, args)
    if(res.meta.code === 200) {
      yield put(receiveVideos(res.data))
      yield put(updateFilteredUnits(res.data.units))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # courses
// ==========================
function* fetchCourses(args) {
  try {
    const courses = ['english', 'mathematics', 'japanese', 'science', 'social_studies']
    const data = yield courses.map((cource, i) => {
       return call(ApiClient.fetchCoursesApi, {
        accessToken: args.accessToken,
        cource: cource
      })
    })
    let coursesInfo = {}
    data.map((res, i) => {
      if(res.meta.code === 401) {
        location.hash = '/login'
        return false
      }
      let c = res.data.grade[0].subjects
      coursesInfo[res.data.course_name] = c.concat(res.data.grade[1].subjects)
    })
    yield put(receiveCourses(coursesInfo))
  }
  catch (error) {
    showErrorMessage(error)
  }
}


// ==========================
// # jukuLearnings
// ==========================
function* fetchJukuLearningsCurrent(args) {
  try {
    const res = yield call(ApiClient.fetchJukuLearningsCurrentApi, args)
    if(res.meta.code === 200) {
      yield put(receiveJukuLearnings(res.data.learnings))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}
function* fetchJukuLearningsArchives(args) {
  try {
    const res = yield call(ApiClient.fetchJukuLearningsArchivesApi, args)
    if(res.meta.code === 200) {
      yield put(receiveJukuLearnings(res.data.learnings))
      yield put(updateCurrentPage(args.page))
      yield put(isLastPage(res.data.learnings.length < args.perPage))
    } else {

    }
  }
  catch (error) {
    showErrorMessage(error)
  }
}

function showErrorMessage(error) {
  if (error.meta) {
    if (error.meta.code === 401) {
      location.hash = '/login'
      return false
    }
    put(updateAlerts(error.meta.error_messages))
  }
  put(updateAlerts("サーバーエラーが発生しています"))
  console.log(error)
}

export default function* rootSaga() {
  yield [
    takeEvery(REQUEST_LOGIN, postLogin),
    takeEvery(REQUEST_LOGOUT, logout),
    takeEvery(REQUEST_USER, fetchUser),
    takeEvery(REQUEST_USER_PRIVACY_SETTINGS, fetchPrivacySettings),
    takeEvery(UPDATE_PRIVATE_FLAG, updatePrivateFlag),
    takeEvery(UPDATE_NICKNAME, postNickname),
    takeEvery(UPDATE_AVATAR, postAvatar),
    takeEvery(REQUEST_SCHOOLBOOKS, requestSchoolbooks),
    takeEvery(UPDATE_SCHOOLBOOKS_SETTING, updateSchoolbooks),
    takeEvery(REQUEST_SEARCH_WORDS, fetchSearchWords),
    takeEvery(POST_SEARCHED_WORD, postSearchedWord),
    takeEvery(REQUEST_SEARCH_VIDEOS, fetchSearchVideos),
    takeEvery(REQUEST_SEARCH_UNITS, fetchSearchUnits),
    takeEvery(REQUEST_VIDEO_TAGS, fetchVideoTags),
    takeEvery(REQUEST_VIDEO, fetchVideo),
    takeEvery(REQUEST_VIDEOS, fetchVideos),
    takeEvery(PLAY_AND_POSITION_BAR_CLICK, postPlayAndPositionBarClick),
    takeEvery(ADD_BOOKMARK, addBookmark),
    takeEvery(DELETE_BOOKMARK_VIDEO, deleteBookmarkVideo),
    takeEvery(DELETE_BOOKMARK, deleteBookmark),
    takeEvery(REQUEST_BOOKMARKS, fetchBookmarks),
    takeEvery(REQUEST_QUESTIONS, fetchQuestions),
    takeEvery(RESOLVE_QUESTION, resolveQuestion),
    takeEvery(UNRESOLVE_QUESTION, unresolveQuestion),
    takeEvery(DELETE_QUESTION, deleteQuestions),
    takeEvery(REQUEST_QUESTION, fetchQuestion),
    takeEvery(CREATE_QUESTION, createQuestion),
    takeEvery(CALL_CREATE_QUESTION, callCreateQuestion),
    takeEvery(CALL_CREATE_QUESTION_BY_VIDEO, callCreateQuestionByVideo),
    takeEvery(UPDATE_QUESTION_READ, updateQuestionRead),
    takeEvery(REQUEST_QUESTION_DRAFT, fetchQuestionDraft),
    takeEvery(CREATE_QUESTION_BY_VIDEO, createQuestionByVideo),
    takeEvery(UPDATE_QUESTION, updateQuestion),
    takeEvery(UPDATE_QUESTION_BY_VIDEO, updateQuestionByVideo),
    takeEvery(CALL_UPDATE_QUESTION, callUpdateQuestion),
    takeEvery(CALL_UPDATE_QUESTION_BY_VIDEO, callUpdateQuestionByVideo),
    takeEvery(REQUEST_WORKBOOKS, fetchWorkbooks),
    takeEvery(REQUEST_TEACHER_RECOMMENDS, fetchTeacherRecommends),
    takeEvery(REQUEST_TEACHER_DETAIL, fetchTeacherDetail),
    takeEvery(READ_TEACHER_DETAIL, updateReadTeacherDetail),
    takeEvery(REQUEST_HISTORIES, fetchHistories),
    takeEvery(REQUEST_VIDEO_DETAIL, fetchVideoDetail),
    takeEvery(REQUEST_NEWS, fetchNews),
    takeEvery(REQUEST_NEWS_DETAIL, fetchNewsDetail),
    takeEvery(READ_NEWS, updateReadNews),
    takeEvery(REQUEST_NOTIFICATIONS, fetchNotifications),
    takeEvery(SEND_POINT_REQUEST, sendPointRequest),
    takeEvery(POST_PLAY_TIME, postVideoWatched),
    takeEvery(DELETE_HISTORY, deleteHistory),
    takeEvery(HIDE_SCHOOLBOOK_DIALOGS, putSchoolbookDialogs),
    takeEvery(REQUEST_RANKINGS_PERSONAL, fetchRankingsPersonal),
    takeEvery(REQUEST_RANKINGS_PERSONALS, fetchRankingsPersonals),
    takeEvery(REQUEST_RANKINGS_CLASSROOM, fetchRankingsClassroom),
    takeEvery(REQUEST_RANKINGS_CLASSROOMS, fetchRankingsClassrooms),
    takeEvery(REQUEST_LEARNING_PROGRESSES, fetchLearningProgresses),
    takeEvery(REQUEST_COURSES, fetchCourses),
    takeEvery(REQUEST_JUKU_LEARNINGS_CURRENT, fetchJukuLearningsCurrent),
    takeEvery(REQUEST_JUKU_LEARNINGS_ARCHIVES, fetchJukuLearningsArchives)
  ]
}
