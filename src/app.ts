import { PropsWithChildren } from 'react'
import { Capacitor } from '@capacitor/core'
import { StatusBar, Style } from '@capacitor/status-bar'
import { useLaunch } from '@tarojs/taro'
import { initDb } from './db'
import './app.scss'

/**
 * 原生壳内让系统状态栏不遮挡 WebView，保证自定义顶栏可见。
 */
async function setupNativeChrome() {
  if (!Capacitor.isNativePlatform()) return
  try {
    // 1. WebView 不延伸到状态栏下方
    await StatusBar.setOverlaysWebView({ overlay: false })
    // 2. 浅色状态栏文字/图标配白底顶栏
    await StatusBar.setStyle({ style: Style.Light })
    await StatusBar.setBackgroundColor({ color: '#ffffff' })
  } catch (e) {
    console.warn('StatusBar 初始化跳过', e)
  }
}

function App({ children }: PropsWithChildren) {
  useLaunch(() => {
    setupNativeChrome()
    initDb().catch((e) => {
      console.error('数据库初始化失败', e)
    })
  })

  return children
}

export default App
