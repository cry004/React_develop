export const REQUEST_VIDEOS = 'REQUEST_VIDEOS'
export const RECEIVE_VIDEOS = 'RECEIVE_VIDEOS'
export const UPDATE_CURRENT_COURCE = 'UPDATE_CURRENT_COURCE'
export const FILTERED_VIDEOS_UNITS = 'FILTERED_VIDEOS_UNITS'
export const UPDATE_VIDEOS_CURRENT_UNIT = 'UPDATE_VIDEOS_CURRENT_UNIT'

export function requestVideos(accessToken, year = 'c1', subject = 'english_regular') {
  return {
    type: REQUEST_VIDEOS,
    accessToken: accessToken,
    year: year,
    subject: subject,
    isFetching: true
  }
}

export function receiveVideos(data) {
  return {
    type: RECEIVE_VIDEOS,
    completedVideosCount: data.completed_videos_count,
    totalVideosCount: data.total_videos_count,
    schoolbookName: data.schoolbook_name,
    title: {
      schoolName: data.title.school_name,
      subjectName: data.title.subject_name,
      subjectKey: data.title.subject_key,
      subjectType: data.title.subject_type,
      subjectDetailName: data.title.subject_detail_name,
    },
    videosSuggest: {
      type: data.videos_suggest.type,
      videos: data.videos_suggest.videos,
    },
    units: data.units,
    completedTrophiesCount: data.completed_trophies_count,
    totalTrophiesCount: data.total_trophies_count,
    currentSubject: data.title.subject_key,
    isFetching: false
  }
}

export function updateFilteredUnits(units = []) {
  return {
    type: FILTERED_VIDEOS_UNITS,
    filteredUnits: units
  }
}

export function updateCurrentCource(year = 'c1', subject = 'english_regular') {
  return {
    type: UPDATE_CURRENT_COURCE,
    year: year,
    subject: subject
  }
}

export function updateVideosCurrentUnit(currentUnitIndex = null) {
  return {
    type: UPDATE_VIDEOS_CURRENT_UNIT,
    currentUnitIndex: currentUnitIndex
  }
}

