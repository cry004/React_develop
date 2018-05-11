export function separateByThreeDigits(str) {
  if (str === null || str === undefined) {
    str = 0
  }
  return str.toString().replace(/(\d)(?=(\d{3})+$)/g , '$1,')
}

export function getPeriodTypeFromHash(hash) {
  const periodTypes = hash.match(/period_type=(.*?)(&|$)/)
  const periodType = periodTypes.length > 0 ? periodTypes[1] : 'last_7_days'
  return periodType
}