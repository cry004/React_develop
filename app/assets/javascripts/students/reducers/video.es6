import { REQUEST_VIDEO,
  RECEIVE_VIDEO,
  UPDATE_VIDEO_ID,
  PLAY_VIDEO,
  PAUSE_VIDEO,
  UPDATE_IS_ENLARGED,
  UPDATE_CURRENT_TIME,
  UPDATE_CURRENT_CHAPTER,
  UPDATE_RATE_HIGH,
  UPDATE_IS_SHOW_OVERLAY,
  UPDATE_IS_VIDEO_LOADED,
  UPDATE_VOLUME,
  UPDATE_IS_MUTE,
  UPDATE_PLAY_TIME,
  UPDATE_PLAY_START_TIME,
  RECEIVE_BOOKMARK,
  UPDATE_VIDEO_CURRENT_TAB,
  INIT_VIDEO,
  TEXT_IMAGE_LOADED
} from '../actions/video.es6'


const initialState = {
  chapters: [],
  currentChapter: 1,
  answerUrl: "",
  checktestUrl: "",
  kaisetuWebUrl: "",
  currentStudentWatchedCount: 0,
  doubleSpeedVideoUrl: "",
  duration: 0,
  durationTime: "00:00",
  id: 1,
  nextId: 1,
  lockedVideo: false,
  name: "",
  nextVideos: [],
  previousVideos: [],
  subject: {
    key: "english",
    name: "英語"
  },
  subname: "",
  thumbnailUrl: "",
  title: {
    school_name: "中学",
    subject_detail_name: "中１",
    subject_name: "英語",
    subject_type: "通常学習編"
  },
  totalWatchedCount: 0,
  videoUrl: "",
  currentVideo: null,
  isDoubleVideo: false,
  isPaused: true,
  volume: 1.00,
  isVideoLoaded: false,
  isEnlarged: false,
  isHighRate: false,
  isShowOverlay: true,
  currentTime: 0,
  playTime: 0,
  playStartTime: 0,
  videos: [],
  currentTab: 'videos',
  isFetching: false
}

function video(state = initialState, action) {
  switch (action.type) {
    case REQUEST_VIDEO:
      return Object.assign({}, state, {
        accessToken: action.accessToken,
        id: action.id,
        isFetching: action.isFetching
      })
    case RECEIVE_VIDEO:
      return Object.assign({}, state, {
        accessToken: action.accessToken,
        answerUrl: action.answerUrl,
        chapters: action.chapters,
        checktestUrl: action.checktestUrl,
        kaisetuWebUrl: action.kaisetuWebUrl,
        currentStudentWatchedCount: action.currentStudentWatchedCount,
        doubleSpeedVideoUrl: action.doubleSpeedVideoUrl,
        duration: action.duration,
        durationTime: action.durationTime,
        id: action.id,
        lockedVideo: action.lockedVideo,
        name: action.name,
        nextVideos: action.nextVideos,
        previousVideos: action.previousVideos,
        subject: action.subject,
        subname: action.subname,
        thumbnailUrl: action.thumbnailUrl,
        title: action.title,
        totalWatchedCount: action.totalWatchedCount,
        videoUrl: action.videoUrl,
        isBookmarked: action.isBookmarked,
        isFetching: action.isFetching
      })
    case TEXT_IMAGE_LOADED:
      return Object.assign({}, state, {
        isImageLoaded: action.isImageLoaded
      })
    case UPDATE_VIDEO_ID:
      return Object.assign({}, state, {
        nextId: action.nextId
      })
    case PLAY_VIDEO:
      return Object.assign({}, state, {
        isPaused: action.isPaused
      })
    case PAUSE_VIDEO:
      return Object.assign({}, state, {
        isPaused: action.isPaused
      })
    case UPDATE_IS_ENLARGED:
      return Object.assign({}, state, {
        isEnlarged: action.isEnlarged
      })
    case UPDATE_CURRENT_TIME:
      return Object.assign({}, state, {
        currentTime: action.currentTime
      })
    case UPDATE_CURRENT_CHAPTER:
      return Object.assign({}, state, {
        currentChapter: action.currentChapter
      })
    case UPDATE_RATE_HIGH:
      return Object.assign({}, state, {
        isHighRate: action.isHighRate
      })
    case UPDATE_IS_SHOW_OVERLAY:
      return Object.assign({}, state, {
        isShowOverlay: action.isShowOverlay
      })
    case UPDATE_IS_VIDEO_LOADED:
      return Object.assign({}, state, {
        isVideoLoaded: action.isVideoLoaded
      })      
    case UPDATE_VOLUME:
      return Object.assign({}, state, {
        volume: action.volume
      })
    case UPDATE_IS_MUTE:
      return Object.assign({}, state, {
        isMute: action.isMute
      })
    case UPDATE_PLAY_TIME:
      return Object.assign({}, state, {
        playTime: action.playTime
      })
    case UPDATE_PLAY_START_TIME:
      return Object.assign({}, state, {
        playStartTime: action.playStartTime
      })
    case RECEIVE_BOOKMARK:
      return Object.assign({}, state, {
        isBookmarked: action.isBookmarked
      })
    case UPDATE_VIDEO_CURRENT_TAB:
      return Object.assign({}, state, {
        currentTab: action.currentTab
      })
    case INIT_VIDEO:
      return initialState
    default:
      return state
  }
}

export default video