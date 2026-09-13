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

const ICON_IDLE = '#7a858c'
const ICON_ACTIVE = '#3a8f83'
const TAB_ICON = 20
const CENTER_ICON = 24
const ACTION_ICON = 22

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

const ACTIONS = [
  {
    label: '记一笔',
    url: '/pages/ledger/edit',
    tone: 'ledger',
    icon: Wallet,
    color: '#3a8f83',
  },
  {
    label: '加个任务',
    url: '/pages/tasks/edit',
    tone: 'task',
    icon: ListTodo,
    color: '#6b9bc3',
  },
  {
    label: '写两句',
    url: '/pages/notes/edit',
    tone: 'note',
    icon: FileText,
    color: '#7a92a8',
  },
] as const

function resolveSelected(route: string) {
  if (route.includes('calendar')) return 'calendar'
  if (route.includes('tasks')) return 'tasks'
  if (route.includes('mine')) return 'mine'
  return 'ledger'
}

/** 底部 Dock：中间 + 弹出三个快捷入口 */
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

      <View className={`app-dock__panel ${open ? 'is-open' : ''}`}>
        {ACTIONS.map((item) => (
          <View
            key={item.url}
            className={`app-dock__action app-dock__action--${item.tone}`}
            onClick={() => onAction(item.url)}
          >
            <View className='app-dock__action-icon'>
              <AppIcon icon={item.icon} size={ACTION_ICON} color={item.color} />
            </View>
            <Text className='app-dock__action-label'>{item.label}</Text>
          </View>
        ))}
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
