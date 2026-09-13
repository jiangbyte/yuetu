/**
 * H5：将 JSON 触发浏览器下载；其它端降级为复制到剪贴板。
 */
export async function downloadJsonFile(filename: string, data: unknown) {
  // 1. 序列化为可读 JSON
  const text = JSON.stringify(data, null, 2)

  // 2. H5 用 Blob 下载；无 document 时写入剪贴板兜底
  if (typeof document !== 'undefined') {
    const blob = new Blob([text], { type: 'application/json;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    a.click()
    URL.revokeObjectURL(url)
    return 'download' as const
  }

  const Taro = await import('@tarojs/taro')
  await Taro.default.setClipboardData({ data: text })
  return 'clipboard' as const
}
