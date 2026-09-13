/** 格式化金额显示 */
export function formatMoney(value: number) {
  const n = Number(value) || 0
  return n.toLocaleString('zh-CN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
}

/** 带正负号的金额文案 */
export function signedMoney(type: 'income' | 'expense', value: number) {
  const prefix = type === 'income' ? '+' : '-'
  return `${prefix}${formatMoney(value)}`
}
