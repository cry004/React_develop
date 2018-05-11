import { SELECT_SUBJECT,
  UPDATE_TEXT,
  UPDATE_PREVIEW,
  UPDATE_IMAGE,
  CREATE_QUESTION,
  RECEIVE_CREATE_QUESTION,
  UPDATE_QUESTION,
  UPDATE_QUESTION_BY_VIDEO,
  RECEIVE_POINT_REQUEST,
  UPDATE_CREATE_QUESTION_ID,
  UPDATE_CREATE_QUESTION_STATUS,
  INIT_CREATE_QUESTION,
  INIT_IMAGE_FILE,
  RECEIVE_DRAFT,
  UPDATE_CREATE_QUESTION_SENDING,
  INIT_CREATE_QUESTION_ALL,
  CREATE_QUESTION_ERROR_MESSAGE
} from '../actions/createQuestion.es6'

const initialState = {
  selectedSubject: 'english',
  imageFile: null,
  text: "",
  prevImageSrc: "",
  videoId: null,
  position: null,
  date: "",
  questionId: null,
  resourceUrl: null,
  isRequestingPoint: false,
  status: "initial",
  questionType: "other",
  isSending: false,
  errorMessage: []
}

function createQuestion(state = initialState, action) {
  switch (action.type) {
    case INIT_CREATE_QUESTION:
      return Object.assign({}, state, {
        text: action.text,
        selectedSubject: action.selectedSubject,
        imageFile: action.imageFile,
        isSending: action.isSending
      })
    case INIT_IMAGE_FILE:
      return Object.assign({}, state, {
        imageFile: action.imageFile
      })
    case SELECT_SUBJECT:
      return Object.assign({}, state, {
        selectedSubject: action.selectedSubject
      })
    case UPDATE_TEXT:
      return Object.assign({}, state, {
        text: action.text
      })
    case UPDATE_PREVIEW:
      return Object.assign({}, state, {
        prevImageSrc: action.prevImageSrc
      })
    case UPDATE_IMAGE:
      return Object.assign({}, state, {
        imageFile: action.imageFile
      })
    case CREATE_QUESTION:
      return Object.assign({}, state, {
        videoId: action.videoId,
        position: action.position
      })
    case RECEIVE_CREATE_QUESTION:
      return Object.assign({}, state, {
        date: action.date,
        questionId: action.questionId,
        resourceUrl: action.resourceUrl,
        questionType: action.questionType
      })
    case UPDATE_QUESTION:
      return Object.assign({}, state, {
        isSending: action.isSending
      })
    case UPDATE_QUESTION_BY_VIDEO:
      return Object.assign({}, state, {
        isSending: action.isSending
      })
    case RECEIVE_POINT_REQUEST:
      return Object.assign({}, state, {
        isRequestingPoint: action.isRequestingPoint
      })
    case UPDATE_CREATE_QUESTION_ID:
      return Object.assign({}, state, {
        questionId: action.questionId,
        status: action.status
      })
    case UPDATE_CREATE_QUESTION_STATUS:
      return Object.assign({}, state, {
        status: action.status
      })
    case RECEIVE_DRAFT:
      return Object.assign({}, state, {
        date: action.date,
        text: action.text,
        resourceUrl: action.resourceUrl,
        questionType: action.questionType,
        selectedSubject: action.selectedSubject
      })
    case UPDATE_CREATE_QUESTION_SENDING:
      return Object.assign({}, state, {
        isSending: action.isSending
      })
    case CREATE_QUESTION_ERROR_MESSAGE:
      return Object.assign({}, state, {
        errorMessage: action.errorMessage
      })
    case INIT_CREATE_QUESTION_ALL:
      return Object.assign({}, state, initialState)
    default:
      return state
  }
}

export default createQuestion