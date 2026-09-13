import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { ChevronRight } from 'lucide-react'
import { AppCard } from '../../components/AppCard'
import { AppDock } from '../../components/AppDock'
import { AppIcon } from '../../components/AppIcon'
import { AppPageHeader } from '../../components/AppPageHeader'
import './index.scss'

const MENUS = [
  {
    title: '分类管理',
    desc: '支出 / 收入 / 笔记 / 任务分类。',
    url: '/pages/categories/index',
    action: '管理',
  },
  {
    title: '数据',
    desc: '导出备份或清空本机数据。',
    url: '/pages/mine/data',
    action: '进入',
  },
  {
    title: '关于月兔',
    desc: '版本与产品说明。',
    url: '/pages/mine/about',
    action: '查看',
  },
] as const

export default function MinePage() {
  return (
    <View className='mine-page has-page-header'>
      <AppPageHeader title='我的' />
      {MENUS.map((item) => (
        <View
          key={item.url}
          onClick={() => Taro.navigateTo({ url: item.url })}
        >
          <AppCard className='mine-page__card'>
            <View className='mine-page__nav'>
              <Text className='mine-page__nav-title'>{item.title}</Text>
              <View className='mine-page__nav-right'>
                <Text className='mine-page__link'>{item.action}</Text>
                <AppIcon icon={ChevronRight} size={16} color='#8c8c8c' />
              </View>
            </View>
            <Text className='mine-page__nav-desc'>{item.desc}</Text>
          </AppCard>
        </View>
      ))}
      <AppDock />
    </View>
  )
}
