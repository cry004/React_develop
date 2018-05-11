export const SELECT_SUBJECT = 'SELECT_SUBJECT'
export const UPDATE_TEXT = 'UPDATE_TEXT'
export const UPDATE_PREVIEW = 'UPDATE_PREVIEW'
export const UPDATE_IMAGE = 'UPDATE_IMAGE'
export const CREATE_QUESTION = 'CREATE_QUESTION'
export const CREATE_QUESTION_BY_VIDEO = 'CREATE_QUESTION_BY_VIDEO'
export const RECEIVE_CREATE_QUESTION = 'RECEIVE_CREATE_QUESTION'
export const UPDATE_QUESTION = 'UPDATE_QUESTION'
export const CALL_UPDATE_QUESTION = 'CALL_UPDATE_QUESTION'
export const UPDATE_QUESTION_BY_VIDEO = 'UPDATE_QUESTION_BY_VIDEO'
export const CALL_UPDATE_QUESTION_BY_VIDEO = 'CALL_UPDATE_QUESTION_BY_VIDEO'
export const SEND_POINT_REQUEST = 'SEND_POINT_REQUEST'
export const RECEIVE_POINT_REQUEST = 'RECEIVE_POINT_REQUEST'
export const UPDATE_CREATE_QUESTION_ID = 'UPDATE_CREATE_QUESTION_ID'
export const REQUEST_QUESTION_DRAFT = 'REQUEST_QUESTION_DRAFT'
export const UPDATE_CREATE_QUESTION_STATUS = 'UPDATE_CREATE_QUESTION_STATUS'
export const INIT_CREATE_QUESTION = 'INIT_CREATE_QUESTION'
export const INIT_IMAGE_FILE = 'INIT_IMAGE_FILE'
export const RECEIVE_DRAFT = 'RECEIVE_DRAFT'
export const INIT_CREATE_QUESTION_ALL = 'INIT_CREATE_QUESTION_ALL'
export const UPDATE_CREATE_QUESTION_SENDING = 'UPDATE_CREATE_QUESTION_SENDING'
export const CREATE_QUESTION_ERROR_MESSAGE = 'CREATE_QUESTION_ERROR_MESSAGE'
export const CALL_CREATE_QUESTION = 'CALL_CREATE_QUESTION'
export const CALL_CREATE_QUESTION_BY_VIDEO = 'CALL_CREATE_QUESTION_BY_VIDEO'

export function initCreateQuestion() {
  return {
    type: INIT_CREATE_QUESTION,
    text: "",
    selectedSubject: null,
    imageFile: null,
    isSending: false
  }
}

export function initImageFile() {
  return {
    type: INIT_IMAGE_FILE,
    imageFile: null
  }
}

export function updateCreateQuestionId(questionId, status =  "initial") {
  return {
    type: UPDATE_CREATE_QUESTION_ID,
    questionId: questionId,
    status: status
  }
}

export function updateCreateQuestionStatus(status = "initial") {
  return {
    type: UPDATE_CREATE_QUESTION_STATUS,
    status: status
  }
}

export function requestQuestionDraft(accessToken = "", id) {
  return {
    type: REQUEST_QUESTION_DRAFT,
    accessToken: accessToken,
    id: id
  }
}

export function selectSubject(selectedSubject) {
  return {
    type: SELECT_SUBJECT,
    selectedSubject: selectedSubject
  }
}

export function updateText(text) {
  return {
    type: UPDATE_TEXT,
    text: text
  }
}

export function updateImage(file) {
  return {
    type: UPDATE_IMAGE,
    imageFile: file
  }
}

export function updatePreview(prevImageSrc) {
  return {
    type: UPDATE_PREVIEW,
    prevImageSrc: prevImageSrc
  }
}

export function createQuestion(accessToken = "") {
  return {
    type: CREATE_QUESTION,
    accessToken: accessToken
  }
}

export function callCreateQuestion(accessToken = "") {
  return {
    type: CALL_CREATE_QUESTION,
    accessToken: accessToken
  }
}

export function createQuestionByVideo(accessToken = "", videoId = null, position = null) {
  return {
    type: CREATE_QUESTION_BY_VIDEO,
    accessToken: accessToken,
    videoId: videoId,
    position: position
  }
}

export function callCreateQuestionByVideo(accessToken = "", videoId = null, position = null) {
  return {
    type: CALL_CREATE_QUESTION_BY_VIDEO,
    accessToken: accessToken,
    videoId: videoId,
    position: position
  }
}

export function updateQuestion(accessToken = "", questionId, createFlag, withoutVideo = {}) {
  return {
    type: UPDATE_QUESTION,
    accessToken: accessToken,
    questionId: questionId,
    createFlag: createFlag,
    withoutVideo: withoutVideo
  }
}

export function callUpdateQuestion(accessToken = "", questionId, createFlag, withoutVideo = {}) {
  return {
    type: CALL_UPDATE_QUESTION,
    accessToken: accessToken,
    questionId: questionId,
    createFlag: createFlag,
    withoutVideo: withoutVideo,
    isSending: true
  }
}

export function updateQuestionByVideo(accessToken = "", questionId, createFlag, withVideo = {}) {
  return {
    type: UPDATE_QUESTION_BY_VIDEO,
    accessToken: accessToken,
    questionId: questionId,
    createFlag: createFlag,
    withVideo: withVideo
  }
}

export function callUpdateQuestionByVideo(accessToken = "", questionId, createFlag, withVideo = {}) {
  return {
    type: CALL_UPDATE_QUESTION_BY_VIDEO,
    accessToken: accessToken,
    questionId: questionId,
    createFlag: createFlag,
    withVideo: withVideo,
    isSending: true
  }
}

export function updateCreateQuestionSending(isSending = false) {
  return {
    type: UPDATE_CREATE_QUESTION_SENDING,
    isSending: isSending
  }
}

export function receiveCreateQuestion(data) {
  return {
    type: RECEIVE_CREATE_QUESTION,
    date: data.date,
    questionId: data.question_id,
    resourceUrl: data.resource_url,
    subject: data.subject,
    questionType: !!data.resource_url ? 'video' : 'other',
  }
}

export function receiveDraft(data) {
  return {
    type: RECEIVE_DRAFT,
    date: data.date,
    text: data.body,
    resourceUrl: !!data.image ? data.image.desktop.resource_url : null,
    questionType: data.type,
    selectedSubject: !!data.subject ? data.subject.key : null
  }
}

export function sendPointRequest(accessToken = "") {
  return {
    type: SEND_POINT_REQUEST,
    accessToken: accessToken,
    isRequestingPoint: true,
  }
}

export function receivePointRequest() {
  return {
    type: RECEIVE_POINT_REQUEST,
    isRequestingPoint: false, 
  }
}

export function createQuestionErrorMessage(errorMessage) {
  return {
    type: CREATE_QUESTION_ERROR_MESSAGE,
    errorMessage: errorMessage,
    isSending: false
  }
}

export function initCreateQuestionAll() {
  return {
    type: INIT_CREATE_QUESTION_ALL
  }
}