import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { AppCard } from '../../components/AppCard'
import { AppPageHeader } from '../../components/AppPageHeader'
import './about.scss'

const GITHUB_URL = 'https://github.com/jiangbyte/yuetu'
const AUTHOR_NAME = 'Charlie Zhang'
const AUTHOR_GITHUB = 'https://github.com/jiangbyte'
const AUTHOR_EMAIL = 'jiangbytebiz@163.com'

const TECH_STACK = [
  'Taro 4 · React · TypeScript',
  'SQLite（H5：sql.js + IndexedDB；RN：op-sqlite）',
  'Apache ECharts',
  'Capacitor（Android APK）',
  'pnpm',
]

/**
 * 复制文案并提示，便于在 App 内分享链接或邮箱。
 */
function copyText(label: string, value: string) {
  // 1. 写入剪贴板
  // 2. 轻提示成功
  Taro.setClipboardData({ data: value }).then(() => {
    Taro.showToast({ title: `已复制${label}`, icon: 'none' })
  })
}

export default function MineAboutPage() {
  return (
    <View className='mine-about has-page-header'>
      <AppPageHeader title='关于月兔' showBack />
      <AppCard className='mine-about__card'>
        <Text className='mine-about__name'>月兔</Text>
        <Text className='mine-about__tag'>本地笔记 · 任务 · 记账</Text>
        <Text className='mine-about__desc'>
          本地优先的个人账本与事项工具：流水记账、日历总览、任务与笔记。数据只保存在本机，不上传云端。
        </Text>
        <Text className='mine-about__ver'>版本 1.1.0</Text>
      </AppCard>

      <AppCard className='mine-about__card'>
        <Text className='mine-about__section'>技术栈</Text>
        {TECH_STACK.map((item) => (
          <Text key={item} className='mine-about__stack-item'>
            · {item}
          </Text>
        ))}
      </AppCard>

      <AppCard className='mine-about__card'>
        <Text className='mine-about__section'>项目与作者</Text>
        <View
          className='mine-about__row'
          onClick={() => copyText('仓库地址', GITHUB_URL)}
        >
          <Text className='mine-about__label'>GitHub</Text>
          <Text className='mine-about__value'>jiangbyte/yuetu</Text>
        </View>
        <View className='mine-about__row'>
          <Text className='mine-about__label'>作者</Text>
          <Text className='mine-about__value'>{AUTHOR_NAME}</Text>
        </View>
        <View
          className='mine-about__row'
          onClick={() => copyText('主页', AUTHOR_GITHUB)}
        >
          <Text className='mine-about__label'>主页</Text>
          <Text className='mine-about__value'>github.com/jiangbyte</Text>
        </View>
        <View
          className='mine-about__row mine-about__row--last'
          onClick={() => copyText('邮箱', AUTHOR_EMAIL)}
        >
          <Text className='mine-about__label'>邮箱</Text>
          <Text className='mine-about__value'>{AUTHOR_EMAIL}</Text>
        </View>
        <Text className='mine-about__hint'>点击 GitHub / 主页 / 邮箱可复制</Text>
      </AppCard>
    </View>
  )
}
