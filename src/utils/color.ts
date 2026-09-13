/** 将 #RRGGBB 转为带透明度的 rgba，用于分类色浅底 */
export function hexToRgba(hex: string, alpha: number) {
  const raw = hex.replace('#', '').trim()
  if (raw.length !== 3 && raw.length !== 6) {
    return `rgba(26, 26, 26, ${alpha})`
  }
  const full =
    raw.length === 3
      ? raw
          .split('')
          .map((c) => c + c)
          .join('')
      : raw
  const n = Number.parseInt(full, 16)
  const r = (n >> 16) & 255
  const g = (n >> 8) & 255
  const b = n & 255
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}
