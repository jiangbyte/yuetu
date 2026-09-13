import { useEffect } from 'react'
import { View } from '@tarojs/components'
import Taro from '@tarojs/taro'

/** 笔记列表已合并到事项页，进入时跳转并打开笔记 Tab */
export default function NotesRedirectPage() {
  useEffect(() => {
    try {
      Taro.setStorageSync('yuetu_workspace_tab', 'note')
    } catch {
      // ignore
    }
    Taro.switchTab({ url: '/pages/tasks/index' })
  }, [])

  return <View />
}
