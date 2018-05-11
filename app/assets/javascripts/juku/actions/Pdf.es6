export const JOIN_PDF = 'JOIN_PDF'
export const JOINED_PDF = 'JOINED_PDF'
export const ERRORD_JOIN_PDF = 'ERRORD_JOIN_PDF'
export const CHECK_PDF = 'CHECK_PDF'
export const YES_PDF = 'YES_PDF'
export const NO_PDF = 'NO_PDF'
export const DEFAULT_PDF = 'DEFAULT_PDF'

export function joinPdfs(pdfList, envName) {
  return {
    type: JOIN_PDF,
    pdfList,
    envName
  }
}

export function joinedPdfs(json) {
  return {
    type: JOINED_PDF,
    json
  }
}

export function checkJoinPdfUrl(url) {
  return {
    type: CHECK_PDF,
    url
  }
}

export function erroredJoinPdfs(message) {
  return {
    type: ERRORD_JOIN_PDF,
    message
  }
}

export function setDefaultPdf() {
  return {
    type: DEFAULT_PDF
  }
}

export function yesPdf() {
  return {
    type: YES_PDF
  }
}

export function noPdf(status, errorMessage = '') {
  return {
    type: NO_PDF,
    status,
    errorMessage
  }
}
