import type { ReactNode } from 'react'
import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { ChevronLeft } from 'lucide-react'
import { AppIcon } from '../AppIcon'
import './index.scss'

/** 页面顶栏：一级页标题；二级页带返回 */
export function AppPageHeader({
  title,
  showBack = false,
  right,
}: {
  title: string
  showBack?: boolean
  right?: ReactNode
}) {
  const onBack = () => {
    // 1. 有历史栈则返回
    // 2. 否则回流水 Tab，避免 Capacitor 下卡死在二级页
    const pages = Taro.getCurrentPages()
    if (pages.length > 1) {
      Taro.navigateBack()
      return
    }
    Taro.switchTab({ url: '/pages/ledger/index' })
  }

  return (
    <View className={`app-page-header ${showBack ? 'has-back' : ''}`}>
      <View className='app-page-header__inner'>
        {showBack ? (
          <View className='app-page-header__back' onClick={onBack}>
            <AppIcon icon={ChevronLeft} size={22} color='#1a1a1a' />
            <Text className='app-page-header__back-text'>返回</Text>
          </View>
        ) : (
          <View className='app-page-header__side' />
        )}
        <Text className='app-page-header__title'>{title}</Text>
        <View className='app-page-header__side app-page-header__side--right'>
          {right}
        </View>
      </View>
    </View>
  )
}
