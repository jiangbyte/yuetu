/** 当前年月 YYYY-MM */
export function currentYearMonth() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

/** 月份加减 */
export function shiftYearMonth(ym: string, delta: number) {
  const [y, m] = ym.split('-').map(Number)
  const d = new Date(y, m - 1 + delta, 1)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

/** 月起止 ISO 日期 */
export function monthRange(ym: string) {
  const [y, m] = ym.split('-').map(Number)
  const start = `${ym}-01`
  const last = new Date(y, m, 0).getDate()
  const end = `${ym}-${String(last).padStart(2, '0')}`
  return { start, end }
}

/** 今天 YYYY-MM-DD */
export function todayDate() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

/** 日分组标题：03月 12日 周二 */
export function formatDayLabel(isoDate: string) {
  const d = new Date(`${isoDate}T00:00:00`)
  const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${month}月${day}日 周${week}`
}

/** 截止日期短展示：09月13日 */
export function formatDateShort(isoDate: string) {
  const d = new Date(`${isoDate}T00:00:00`)
  if (Number.isNaN(d.getTime())) return isoDate
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${month}月${day}日`
}

/** 展示用年月 */
export function formatYearMonth(ym: string) {
  const [y, m] = ym.split('-')
  return `${y}年${Number(m)}月`
}

/** 短年月：2019/2 */
export function formatYearMonthShort(ym: string) {
  const [y, m] = ym.split('-')
  return `${Number(m)}/${y}`
}

/** 从 YYYY-MM-DD 取年月 */
export function yearMonthOf(date: string) {
  return date.slice(0, 7)
}

/** 构建月历格子（含上月/下月占位） */
export function buildMonthGrid(ym: string) {
  const [y, m] = ym.split('-').map(Number)
  const first = new Date(y, m - 1, 1)
  const daysInMonth = new Date(y, m, 0).getDate()
  const startWeekday = first.getDay()
  const cells: Array<{
    date: string
    day: number
    inMonth: boolean
    isToday: boolean
  }> = []
  const today = todayDate()

  // 上月补齐
  const prevDays = new Date(y, m - 1, 0).getDate()
  for (let i = startWeekday - 1; i >= 0; i--) {
    const day = prevDays - i
    const pm = m === 1 ? 12 : m - 1
    const py = m === 1 ? y - 1 : y
    const date = `${py}-${String(pm).padStart(2, '0')}-${String(day).padStart(2, '0')}`
    cells.push({ date, day, inMonth: false, isToday: date === today })
  }

  for (let day = 1; day <= daysInMonth; day++) {
    const date = `${ym}-${String(day).padStart(2, '0')}`
    cells.push({ date, day, inMonth: true, isToday: date === today })
  }

  // 下月补齐到完整周
  let next = 1
  while (cells.length % 7 !== 0) {
    const nm = m === 12 ? 1 : m + 1
    const ny = m === 12 ? y + 1 : y
    const date = `${ny}-${String(nm).padStart(2, '0')}-${String(next).padStart(2, '0')}`
    cells.push({ date, day: next, inMonth: false, isToday: date === today })
    next += 1
  }

  return cells
}

/** 日标题短格式：15/2 */
export function formatDayShort(isoDate: string) {
  const d = new Date(`${isoDate}T00:00:00`)
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`
}
