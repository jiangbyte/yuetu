import { useState } from 'react'
import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import {
  Calendar,
  FileText,
  ListTodo,
  Plus,
  User,
  Wallet,
  X,
} from 'lucide-react'
import { AppIcon } from '../AppIcon'
import './index.scss'

const ICON_IDLE = '#8c8c8c'
const ICON_ACTIVE = '#1a1a1a'
const TAB_ICON = 20
const CENTER_ICON = 24
const ACTION_ICON = 26

const TABS = [
  {
    key: 'ledger',
    path: '/pages/ledger/index',
    label: '流水',
    icon: Wallet,
  },
  {
    key: 'calendar',
    path: '/pages/calendar/index',
    label: '日历',
    icon: Calendar,
  },
  { key: 'center', path: '', label: '' },
  {
    key: 'tasks',
    path: '/pages/tasks/index',
    label: '事项',
    icon: ListTodo,
  },
  {
    key: 'mine',
    path: '/pages/mine/index',
    label: '我的',
    icon: User,
  },
] as const

/** 以中心按钮为圆心的扇形三点：左 / 顶 / 右 */
const ACTIONS = [
  {
    label: '记一笔',
    hint: '流水',
    url: '/pages/ledger/edit',
    tone: 'ledger',
    icon: Wallet,
    color: '#1a1a1a',
    slot: 'left',
  },
  {
    label: '新任务',
    hint: '待办',
    url: '/pages/tasks/edit',
    tone: 'task',
    icon: ListTodo,
    color: '#5aaa9a',
    slot: 'top',
  },
  {
    label: '写笔记',
    hint: '备忘',
    url: '/pages/notes/edit',
    tone: 'note',
    icon: FileText,
    color: '#666666',
    slot: 'right',
  },
] as const

function resolveSelected(route: string) {
  if (route.includes('calendar')) return 'calendar'
  if (route.includes('tasks')) return 'tasks'
  if (route.includes('mine')) return 'mine'
  return 'ledger'
}

/** 底部 Dock：中心扇形添加菜单 */
export function AppDock() {
  const [open, setOpen] = useState(false)
  const pages = Taro.getCurrentPages()
  const route = pages[pages.length - 1]?.route || ''
  const selected = resolveSelected(route)

  const onTab = (key: string, path: string) => {
    if (key === 'center') {
      setOpen((v) => !v)
      return
    }
    setOpen(false)
    if (selected === key) return
    Taro.switchTab({ url: path })
  }

  const onAction = (url: string) => {
    setOpen(false)
    try {
      if (url.includes('notes/edit')) {
        Taro.setStorageSync('yuetu_workspace_tab', 'note')
      } else if (url.includes('tasks/edit')) {
        Taro.setStorageSync('yuetu_workspace_tab', 'task')
      }
    } catch {
      // ignore
    }
    Taro.navigateTo({ url })
  }

  return (
    <View className={`app-dock ${open ? 'is-open' : ''}`}>
      {open && (
        <View className='app-dock__mask' onClick={() => setOpen(false)} />
      )}

      <View className={`app-dock__sheet ${open ? 'is-open' : ''}`}>
        <View className='app-dock__fan-bg' />
        <View className='app-dock__sheet-head'>
          <Text className='app-dock__sheet-title'>添加</Text>
          <Text className='app-dock__sheet-sub'>记一笔 · 新任务 · 写笔记</Text>
        </View>

        {/* 圆心对齐中心 +，三支辐条旋转铺成扇形 */}
        <View className='app-dock__hub'>
          {ACTIONS.map((item) => (
            <View
              key={item.url}
              className={`app-dock__spoke app-dock__spoke--${item.slot}`}
            >
              <View
                className={`app-dock__action app-dock__action--${item.tone}`}
                onClick={() => onAction(item.url)}
              >
                <View className='app-dock__action-icon'>
                  <AppIcon
                    icon={item.icon}
                    size={ACTION_ICON}
                    color={item.color}
                  />
                </View>
                <Text className='app-dock__action-label'>{item.label}</Text>
                <Text className='app-dock__action-hint'>{item.hint}</Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      <View className='app-dock__bar'>
        {TABS.map((tab) => {
          if (tab.key === 'center') {
            return (
              <View
                key='center'
                className='app-dock__center-wrap'
                onClick={() => onTab('center', '')}
              >
                <View className={`app-dock__center ${open ? 'is-open' : ''}`}>
                  <AppIcon
                    icon={open ? X : Plus}
                    size={CENTER_ICON}
                    color='#ffffff'
                  />
                </View>
              </View>
            )
          }
          const active = selected === tab.key
          return (
            <View
              key={tab.key}
              className={`app-dock__item ${active ? 'is-active' : ''}`}
              onClick={() => onTab(tab.key, tab.path)}
            >
              <View className='app-dock__item-icon'>
                <AppIcon
                  icon={tab.icon}
                  size={TAB_ICON}
                  color={active ? ICON_ACTIVE : ICON_IDLE}
                />
              </View>
              <Text className='app-dock__item-label'>{tab.label}</Text>
            </View>
          )
        })}
      </View>
    </View>
  )
}
