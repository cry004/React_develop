export const REQUEST_VIDEO = 'REQUEST_VIDEO'
export const RECEIVE_VIDEO = 'RECEIVE_VIDEO'
export const UPDATE_VIDEO_ID = 'UPDATE_VIDEO_ID'
export const TEXT_IMAGE_LOADED = 'TEXT_IMAGE_LOADED'

// play or pause
export const PLAY_VIDEO = 'PLAY_VIDEO'
export const PAUSE_VIDEO = 'PAUSE_VIDEO'

export const UPDATE_IS_ENLARGED = 'UPDATE_IS_ENLARGED'

// update time
export const UPDATE_CURRENT_TIME = 'UPDATE_CURRENT_TIME'

export const UPDATE_PLAY_TIME = 'UPDATE_PLAY_TIME'
export const UPDATE_PLAY_START_TIME = 'UPDATE_PLAY_START_TIME'
export const POST_PLAY_TIME = 'POST_PLAY_TIME'

//update current capter
export const UPDATE_CURRENT_CHAPTER = 'UPDATE_CURRENT_CHAPTER'

export const UPDATE_RATE_HIGH = 'UPDATE_RATE_HIGH'

export const UPDATE_IS_SHOW_OVERLAY = 'UPDATE_IS_SHOW_OVERLAY'
export const UPDATE_IS_VIDEO_LOADED = 'UPDATE_IS_VIDEO_LOADED'

export const UPDATE_VOLUME = 'UPDATE_VOLUME'
export const UPDATE_IS_MUTE = 'UPDATE_IS_MUTE'

export const REQUEST_VIDEO_DETAIL = 'REQUEST_VIDEO_DETAIL'

export const ADD_BOOKMARK = 'ADD_BOOKMARK'
export const DELETE_BOOKMARK_VIDEO = 'DELETE_BOOKMARK_VIDEO'
export const RECEIVE_BOOKMARK = 'RECEIVE_BOOKMARK'

export const UPDATE_VIDEO_CURRENT_TAB = 'UPDATE_VIDEO_CURRENT_TAB'

export const PLAY_AND_POSITION_BAR_CLICK = 'PLAY_AND_POSITION_BAR_CLICK'


export const INIT_VIDEO = 'INIT_VIDEO'

export function requestVideo(accessToken = "", id = 1) {
  return {
    type: REQUEST_VIDEO,
    accessToken: accessToken,
    id: id,
    isFetching: true
  }
}

export function requestVideoDetail(accessToken, id) {
  return {
    type: REQUEST_VIDEO_DETAIL,
    accessToken: accessToken,
    id: id
  }
}

export function updateVideoId(id = 1) {
  return {
    type: UPDATE_VIDEO_ID,
    nextId: id
  }
}

export function receiveVideo(data) {
  return {
    type: RECEIVE_VIDEO,
    answerUrl: data.lessontext_answer_url,
    chapters: data.chapters,
    checktestUrl: data.lessontext_url,
    kaisetuWebUrl: data.kaisetu_web_url,
    currentStudentWatchedCount: data.current_student_watched_count,
    doubleSpeedVideoUrl: data.double_speed_video_url,
    duration: data.duration,
    durationTime: data.duration.text,
    id: data.id,
    lockedVideo: data.locked_video,
    name: data.name,
    nextVideos: data.next_videos,
    previousVideos: data.previous_videos,
    subject: data.subject,
    subname: data.subname,
    thumbnailUrl: data.thumbnail_url,
    title: data.title,
    titleImage: data.title_image,
    totalWatchedCount: data.total_watched_count,
    videoUrl: data.video_url,
    isBookmarked: data.is_bookmarked,
    isFetching: false,
    isImageLoaded: false
  }
}

export function textImageLoaded(isImageLoaded) {
  return {
    type: TEXT_IMAGE_LOADED,
    isImageLoaded: isImageLoaded
  }
}

// play
export function playVideo() {
  return {
    type: PLAY_VIDEO,
    isPaused: false
  }
}

export function clickPlayAndPositionBar(accessToken = "", videoId = 1, position = 0) {
  return {
    type: PLAY_AND_POSITION_BAR_CLICK,
    accessToken: accessToken,
    videoId: videoId,
    position: position
  }
}

// pause
export function pauseVideo() {
  return {
    type: PAUSE_VIDEO,
    isPaused: true
  }
}

// Enlarged
export function updateIsEnlarged(isEnlarged) {
  return {
    type: UPDATE_IS_ENLARGED,
    isEnlarged: isEnlarged
  }
}

// currentTime
export function updateCurrentTime(currentTime) {
  return {
    type: UPDATE_CURRENT_TIME,
    currentTime: currentTime
  }
}

export function updatePlayTime(playTime) {
  return {
    type: UPDATE_PLAY_TIME,
    playTime: playTime
  }
}

export function postPlayTime(accessToken = "", id, playTime = 0) {
  return {
    type: POST_PLAY_TIME,
    accessToken: accessToken,
    id: id,
    playTime: playTime
  }
}

export function updatePlayStartTime(playStartTime) {
  return {
    type: UPDATE_PLAY_START_TIME,
    playStartTime: playStartTime
  }
}

export function updateCurrentChapter(currentChapter) {
  return {
    type: UPDATE_CURRENT_CHAPTER,
    currentChapter: currentChapter
  }
}

export function updateRateHigh(isHighRate) {
  return {
    type: UPDATE_RATE_HIGH,
    isHighRate: isHighRate
  }
}

export function updateIsShowOverlay(isShowOverlay) {
  return {
    type: UPDATE_IS_SHOW_OVERLAY,
    isShowOverlay: isShowOverlay
  }
}

export function updateIsVideoLoaded(isVideoLoaded = true) {
  return {
    type: UPDATE_IS_VIDEO_LOADED,
    isVideoLoaded: isVideoLoaded
  }
}

export function updateVolume(volume) {
  return {
    type: UPDATE_VOLUME,
    volume: volume
  }
}

export function updateIsMute(isMute) {
  return {
    type: UPDATE_IS_MUTE,
    isMute: isMute
  }
}

export function addBookmark(accessToken = "", videoId = null) {
  return {
    type: ADD_BOOKMARK,
    accessToken: accessToken,
    videoId: videoId
  }
}

export function deleteBookmark(accessToken = "", videoId = null) {
  return {
    type: DELETE_BOOKMARK_VIDEO,
    accessToken: accessToken,
    videoId: videoId,
  }
}

export function receiveBookmark(isBookmarked = "false") {
  return {
    type: RECEIVE_BOOKMARK,
    isBookmarked: isBookmarked
  }
}

export function updateVideoCurrentTab(tabname = "videos") {
  return {
    type: UPDATE_VIDEO_CURRENT_TAB,
    currentTab: tabname
  }
}

export function initVideo() {
  return {
    type: INIT_VIDEO
  }
}