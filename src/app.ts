import { PropsWithChildren } from 'react'
import { useLaunch } from '@tarojs/taro'
import { initDb } from './db'
import './app.scss'

function App({ children }: PropsWithChildren) {
  useLaunch(() => {
    initDb().catch((e) => {
      console.error('数据库初始化失败', e)
    })
  })

  return children
}

export default App
