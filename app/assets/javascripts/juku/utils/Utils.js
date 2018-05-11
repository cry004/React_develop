function getJday(day_num) {
  let arr_jday = ["日", "月", "火", "水", "木", "金", "土"];
  return arr_jday[day_num]
}

function edateToJdate(edate, type = 'full') {
  let jDate = ''
  let arr_edate = edate.split('-')
  let date = new Date(arr_edate[0], parseInt(arr_edate[1]) - 1, arr_edate[2])
  let jDay = getJday(date.getDay())
  if(type == 'full') {
    jDate = date.getFullYear() + '年' + (date.getMonth() + 1) + '月' + date.getDate() + '日（' + jDay + '）'
  } else if(type == 'month') {
    jDate = (date.getMonth() + 1) + '月' + date.getDate() + '日（' + jDay + '）'
  }
  
  return jDate
}

function getToday() {
  let date = new Date()
  let today = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate()
  return today
}

export { getJday, edateToJdate, getToday }