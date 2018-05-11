export function createMarkup(str) {
  return {
    __html: !!str ? str.replace(/\r?\n/g, '<br/>') : str
  }
}