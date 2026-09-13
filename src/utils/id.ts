/** 生成本地唯一 ID */
export function createId() {
  return `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 10)}`
}
