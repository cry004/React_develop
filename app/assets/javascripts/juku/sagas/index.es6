import "babel-polyfill"
import { takeEvery } from 'redux-saga'
import { take, put, call, fork, select } from 'redux-saga/effects'
import fetch from 'isomorphic-fetch'

import { receiveSubjects, notReceiveSubjects } from '../actions/Simulator.es6'
import { REQUEST_SUBJECTS } from '../actions/Simulator.es6'
import { receiveStudents, notReceiveStudents } from '../actions/Students.es6'
import { REQUEST_STUDENTS } from '../actions/Students.es6'
import { addErrorMessage } from '../actions/ErrorMessage.es6'
import { receivePrefectures, selectedPrefecture } from '../actions/Prefectures.es6'
import { REQUEST_PREFECTURES } from '../actions/Prefectures.es6'
import { receiveRooms } from '../actions/Rooms.es6'
import { REQUEST_ROOMS } from '../actions/Rooms.es6'
import { receiveBoxes } from '../actions/Boxes.es6'
import { REQUEST_BOXES } from '../actions/Boxes.es6'
import { receiveCurriculums,
  postedCurriculums,
  puttedLearning,
  puttedCurriculums } from '../actions/Curriculums.es6'
import { CHANGE_LEARNINGSTATUS, REQUEST_CURRICULUMS, POST_CURRICULUMS, PUT_CURRICULUMS } from '../actions/Curriculums.es6'
import { receiveLearningReports } from '../actions/Reports.es6'
import { REQUEST_LEARNINGREPORTS, POST_LEARNINGREPORT } from '../actions/Reports.es6'
import { receiveLearnings } from '../actions/Learnings.es6'
import { REQUEST_LEARNINGS } from '../actions/Learnings.es6'
import { receiveHistories } from '../actions/History.es6'
import { REQUEST_HISTORIES } from '../actions/History.es6'
import { CHECK_PDF, yesPdf, noPdf, checkJoinPdfUrl, JOIN_PDF, joinedPdfs, erroredJoinPdfs } from '../actions/Pdf.es6'
import { REQUEST_NUMBEROFWEEKS } from '../actions/NumberOfWeeks.es6'
import { receivedNumberOfWeeks } from '../actions/NumberOfWeeks.es6'
import constants from '../constants.es6'

const networkError = [
  {
    status: "",
    message: "通信エラーが発生しました。ネットワーク接続をご確認ください。"
  }
];
const defaultErrorText = '読み込みに失敗しました。誠に恐縮ですが、しばらく時間を置いて再度お試しください。'

function fetchPrefecturesApi(prefectures) {
  return {
    data: constants.PREFECTURES,
    prefecture: prefectures.prefecture,
    access_token: prefectures.access_token
  }
}

function* fetchPrefectures(prefectures) {
  try {
    const ps = yield call(fetchPrefecturesApi, prefectures)
    yield put( receivePrefectures(ps) )
    yield put( selectedPrefecture(ps.prefecture) )
    if(ps.prefecture != undefined && ps.prefecture != '00') {
      const rm = yield call(fetchRoomsApi, ps)

      if(rm.meta.code !== 200) {
        yield put(addErrorMessage([{
          status: rm.meta.code,
          message: !!rm.meta.error_message ? rm.meta.error_message : defaultErrorText
        }]))
      } else {
        yield put( receiveRooms(rm.data.classrooms) )
      }
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchRoomsApi(rooms) {
  return fetch('/juku/v1/classrooms?prefecture_code=' + rooms.prefecture, {
    headers: {
      'X-Authorization': 'Bearer ' + rooms.access_token
    }
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
  .then(json => json )
}

function* fetchRooms(rooms) {
  try {
    const rm = yield call(fetchRoomsApi, rooms)
    if(rm.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: rm.meta.code,
        message: !!rm.meta.error_message ? rm.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( receiveRooms(rm.data.classrooms) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchCurriculumsApi(curriculums) {
  let req = '/juku/v1/students/'
    + curriculums.student_id
    + '/curriculums?'
    + 'box_id=' + curriculums.selected_box_id
    + '&agreement_id=' + curriculums.selected_agreement_id
    + '&subject_id=' + curriculums.selected_subject_id
  if(curriculums.sub_subject_key){
    req += ('&sub_subject_key=' + curriculums.sub_subject_key)
  }
  return fetch(req, {
    headers: {
      'X-Authorization': 'Bearer ' + curriculums.access_token
    }
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
}

function* fetchCurriculums(curriculums) {
  try {
    const rm = yield call(fetchCurriculumsApi, curriculums)
    if(rm.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: rm.meta.code,
        message: !!rm.meta.error_message ? rm.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( receiveCurriculums(rm) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}




function postCurriculumsApi(curriculums) {
  return fetch('/juku/v1/students/' + curriculums.student_id + '/curriculums',
    {
      method: 'POST',
      headers: {
        'X-Authorization': 'Bearer ' + curriculums.access_token,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        'agreement_id': curriculums.agreement_id,
        'agreement_dow': curriculums.agreement_dow,
        'start_date': curriculums.start_date,
        'end_date': curriculums.end_date,
        'period_id': curriculums.period_id,
        'sub_unit_ids': curriculums.sub_unit_ids,
        'sub_subject_key': curriculums.sub_subject_key
      })
    })
  .then(response => {
    return response.json()
  })
}

function* postCurriculums(curriculums) {
  try {
    const rm = yield call(postCurriculumsApi, curriculums)
    if(rm.meta.code !== 201) {
      yield put(addErrorMessage([{
        status: rm.meta.code,
        message: !!rm.meta.error_message ? rm.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( postedCurriculums(rm) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchBoxesApi(boxes) {
  return fetch('/juku/v1/boxes?classroom_id=' + boxes.classroom_id
   + '&start_date=' + boxes.start_date
   + '&end_date=' + boxes.end_date
  , {
    headers: {
      'X-Authorization': 'Bearer ' + boxes.access_token
    }
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
}

function* fetchBoxes(boxes) {
  try {
    const bx = yield call(fetchBoxesApi, boxes)
    if(bx.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: bx.meta.code,
        message: !!bx.meta.error_message ? bx.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( receiveBoxes(bx) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function* fetchLearningReports(reports) {
  try {
    const rp = yield call(fetchLearningReportsApi, reports)
    if(rp.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: rp.meta.code,
        message: !!rp.meta.error_message ? rp.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( receiveLearningReports(rp) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchLearningReportsApi(reports) {
  return fetch(`/juku/v1/boxes/${reports.selected_box_id}/learning_reports?agreement_id=${reports.selected_agreement_id}&reported_at=${reports.reported_at}&subject_id=${reports.subject_id}`
  , {
    headers: {
      'X-Authorization': 'Bearer ' + reports.access_token
    }
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
}

function* fetchLearnings(learnings) {
  try {
    const rp = yield call(fetchLearningsApi, learnings)
    if(rp.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: rp.meta.code,
        message: !!rp.meta.error_message ? rp.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( receiveLearnings(rp) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchLearningsApi(learnings) {
  let req = '/juku/v1/students/' + learnings.student_id + '/learnings'+ '?box_id=' + learnings.box_id
  if(learnings.status) {
    req += ('&status=' + learnings.status)
  }
  if(learnings.subject_id) {
    req += ('&subject_id=' + learnings.subject_id)
  }
  if(learnings.start_date) {
    req += ('&start_date=' + learnings.start_date)
  }
  if(learnings.end_date) {
    req += ('&end_date=' + learnings.end_date)
  }
  return fetch(
    req
  , {
    headers: {
      'X-Authorization': 'Bearer ' + learnings.access_token
    }
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
}

function* putLearning(learning) {
  try {
    const rp = yield call(putLearningApi, learning)
    if(rp.meta.code !== 201) {
      yield put(addErrorMessage([{
        status: rp.meta.code,
        message: !!rp.meta.error_message ? rp.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( puttedLearning(rp, learning.learnings) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function putLearningApi(learning) {
  let req = '/juku/v1/learnings'
  let obj = {}

  if(learning.learning_id) {
    obj.sub_unit_id=learning.sub_unit_id
    obj.learning_id=learning.learning_id
    obj.box_id=learning.box_id
    obj.status=learning.status
    obj.sent_on=learning.sent_on
    obj.agreement_id=learning.agreement_id
  } else {
    obj.sub_unit_id=learning.sub_unit_id
    obj.student_id=learning.student_id
    obj.period_id=learning.period_id
    obj.box_id=learning.box_id
    obj.status=learning.status
    obj.sent_on=learning.sent_on
    obj.agreement_id=learning.agreement_id
  }
  return fetch(req, {
    method: 'PUT',
    headers: {
      'X-Authorization': 'Bearer ' + learning.access_token,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(obj)
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
      if(response.status === 500) {
        alert('授業の設定を認識できませんでした。\nページをリロードします。')
        location.reload();
      }
    }
    return response.json()
  })
}

function* putCurriculums(param) {
  try {
    const rp = yield call(putCurriculumsApi, param)
    if(rp.meta.code !== 201) {
      yield put(addErrorMessage([{
        status: rp.meta.code,
        message: !!rp.meta.error_message ? rp.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put( puttedCurriculums(rp) )
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function putCurriculumsApi(param) {
  let req = '/juku/v1/curriculums/' + param.curriculum_id
  let obj = {}
  obj.sub_unit_ids=param.sub_unit_ids
  obj.start_date=param.start_date
  obj.end_date=param.end_date

  return fetch(req, {
    method: 'PUT',
    headers: {
      'X-Authorization': 'Bearer ' + param.access_token,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(obj)
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
}

function* postLearningReport(param) {
  try {
    const req = yield call(postLearningReportApi, param)
    if(req.meta.code !== 201) {
      yield put(addErrorMessage([{
        status: req.meta.code,
        message: !!req.meta.error_message ? req.meta.error_message : defaultErrorText
      }]))
    } else {
      location.reload()
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function postLearningReportApi(param) {
  return fetch('/juku/v1/learning_reports', {
    method: 'POST',
    headers: {
      'X-Authorization': 'Bearer ' + param.access_token,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      'box_id': param.box_id,
      'reported_at': param.reported_at,
      'agreement_id': param.selected_agreement_id,
      'student_id': param.student_id
    })
  })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
      if(response.status === 400) {
        alert('授業の設定を認識できませんでした。\nページをリロードします。')
        location.reload();
      }
    }
    return response.json()
  })
}

function* fetchNumberOfWeeks(param) {
  try {
    const req = yield call(fetchNumberOfWeeksApi, param)
    if(req.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: req.meta.code,
        message: !!req.meta.error_message ? req.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put(receivedNumberOfWeeks(req.data.number_of_weeks))
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchNumberOfWeeksApi(param) {
  return fetch('/juku/v1/number_of_weeks'
    + '?start_date=' + param.start_date
    + '&end_date=' + param.end_date
    ,{
      headers: {
        'X-Authorization': 'Bearer ' + param.access_token
      }
    })
  .then(response => {
    if (!response.ok) {
      if(response.status === 401) {
        location.href = "/juku/login"
      }
    }
    return response.json()
  })
  .then(json => json)
}

function* fetchHistories(param) {
  try {
    const req = yield call(fetchHistoriesApi, param)
    if(req.meta.code !== 200) {
      yield put(addErrorMessage([{
        status: req.meta.code,
        message: !!req.meta.error_message ? req.meta.error_message : defaultErrorText
      }]))
    } else {
      yield put(receiveHistories(req))
    }
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(addErrorMessage(catchError(error)))
    }
  }
}

function fetchHistoriesApi(param) {
  let paramStr = '/juku/v1/students/' + param.student_id + '/learnings/histories'
  let paramStr2 = ''
  if(param.start_date){
    if(paramStr2.length < 1) {
      paramStr2 += '?'
    } else {
      paramStr2 += '&'
    }
    paramStr2 += 'start_date='
    paramStr2 += param.start_date
  }
  if(param.end_date) {
    if(paramStr2.length < 1) {
      paramStr2 += '?'
    } else {
      paramStr2 += '&'
    }
    paramStr2 += 'end_date='
    paramStr2 += param.end_date
  }
  if(param.subject_id && param.subject_id != 'null') {
    if(paramStr2.length < 1) {
      paramStr2 += '?'
    } else {
      paramStr2 += '&'
    }
    paramStr2 += 'subject_id='
    paramStr2 += param.subject_id
  }
  if(param.status) {
    if(paramStr2.length < 1) {
      paramStr2 += '?'
    } else {
      paramStr2 += '&'
    }
    paramStr2 += 'status='
    paramStr2 += param.status
  }

  return fetch(paramStr + paramStr2,
    {
      headers: {
        'X-Authorization': 'Bearer ' + param.access_token
      }
    }).then(response => {
      if (!response.ok) {
        if(response.status === 401) {
          location.href = "/juku/login"
        }
      }
      return response.json()
    }
  )
}

function* postJoinPdfs(param) {
  try {
    const req = yield call(postJoinPdfsApi, param)
    yield put(joinedPdfs(req))
    yield call(wait);
    yield put(checkJoinPdfUrl(req.url))
  }
  catch(error) {
    if(navigator.onLine === false) {
      yield put(addErrorMessage(networkError))
    } else {
      yield put(erroredJoinPdfs(error))
    }
  }
}

function wait() {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve();
    }, 5000);
  });
}

function postJoinPdfsApi(param) {
  // // 暗号化
  // var unixTimestampMilli = new Date().getTime();
  // var unixTimestamp = Math.floor( unixTimestampMilli / 1000 );
  // var encrypted = CryptoJS.AES.encrypt(String(unixTimestamp), "SGNqvGi6p0GWvjrWGYnJNSuLElc5VSTS4jQlCqznrTA=");
  return fetch('https://su0sqz0af5.execute-api.ap-northeast-1.amazonaws.com/' + param.envName + '/PdfUtils'
    ,{
      method: 'POST',
      headers: {
        "X-Api-Key": "CVnohm1qJU20bNf54yaT66cJCXNfRjy87y9c1EVk",
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        "method_name": "join",
        "pdfs": param.pdfList,
        // "cipher": encrypted.toString(),
        "invoke_from": "api_gateway"
      })
    })
  .then(response => {
    return response.json()
  })
}

function* checkJoinPdfs(param) {
  let req
  if( typeof (param.url) == "string" || param.url instanceof String) {
    req = yield call(checkJoinPdfsApi, param)
    if(req == 504) {
      yield put(noPdf(req))
    } else if(req == 403 && (yield select(state => state.requestPdf.checkCount < 60 ))) {
      yield call(wait)
      yield put(checkJoinPdfUrl(param.url))
    } else if(req == 200) {
      yield put(yesPdf())
    } else {
      yield put(noPdf(req))
    }
  } else {
    yield put(noPdf(req, param.url.errorMessage))
  }
}

function checkJoinPdfsApi(param) {
  return fetch(param.url,
    {method: 'HEAD'})
    .then(response => {
      return response.status
    })
}


function fetchSubjectsApi(param) {
  return fetch(`/juku/v1/sub_units?sub_subject_key=${param.subject_val}`, {
    headers: {
      'X-Authorization': 'Bearer ' + param.access_token
    }
  })
  .then(response => {
    if (!response.ok) { throw Error(response.statusText) }
    return response.json()
  })
}


function fetchStudentsApi(param) {
  return fetch(`/juku/v1/classrooms/${param.classroom_id}/students`, {
    headers: {
      'X-Authorization': 'Bearer ' + param.access_token,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  })
  .then(response => {
    if (!response.ok) { throw Error(response.statusText) }
    return response.json()
  })
}

function* fetchSubjects(param) {

  try {
    const subjects = yield call(fetchSubjectsApi, param)
    yield put(receiveSubjects(subjects))
  }
  catch(error) {
    yield put(notReceiveSubjects(error))
  }
}

function* fetchStudents(param) {
  try {
    const data = yield call(fetchStudentsApi, param)
    yield put( receiveStudents(data) )
  }
  catch(error) {
    yield put( notReceiveStudents(error) )
  }
}

function catchError(error) {
  return [{
    status: "",
    message: error.toString()
  }]
}

export default function* rootSaga() {
  yield [
    takeEvery(REQUEST_STUDENTS, fetchStudents),
    takeEvery(REQUEST_SUBJECTS, fetchSubjects),
    takeEvery(REQUEST_PREFECTURES, fetchPrefectures),
    takeEvery(REQUEST_BOXES, fetchBoxes),
    takeEvery(REQUEST_ROOMS, fetchRooms),
    takeEvery(REQUEST_CURRICULUMS, fetchCurriculums),
    takeEvery(REQUEST_LEARNINGREPORTS, fetchLearningReports),
    takeEvery(CHANGE_LEARNINGSTATUS, putLearning),
    takeEvery(REQUEST_LEARNINGS, fetchLearnings),
    takeEvery(POST_LEARNINGREPORT, postLearningReport),
    takeEvery(POST_CURRICULUMS, postCurriculums),
    takeEvery(REQUEST_NUMBEROFWEEKS, fetchNumberOfWeeks),
    takeEvery(REQUEST_HISTORIES, fetchHistories),
    takeEvery(PUT_CURRICULUMS, putCurriculums),
    takeEvery(JOIN_PDF, postJoinPdfs),
    takeEvery(CHECK_PDF, checkJoinPdfs)
  ]
}
