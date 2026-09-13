import { useCallback, useEffect, useMemo, useState } from 'react'
import { Input, ScrollView, Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { Check, Search, X } from 'lucide-react'
import { AppDock } from '../../components/AppDock'
import { AppIcon } from '../../components/AppIcon'
import { AppPageHeader } from '../../components/AppPageHeader'
import { PrimaryFab } from '../../components/PrimaryFab'
import { SwipeDelete } from '../../components/SwipeDelete'
import type { Note, Task } from '../../domain/types'
import { taskPriorityLabel } from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import { noteRepo } from '../../repositories/noteRepo'
import { taskRepo } from '../../repositories/taskRepo'
import { formatDateShort, todayDate } from '../../utils/date'
import { hexToRgba } from '../../utils/color'
import './index.scss'

const TAB_KEY = 'yuetu_workspace_tab'
const PAGE_SIZE = 20

export default function WorkspacePage() {
  const [mode, setMode] = useState<'task' | 'note'>('task')
  const [tasks, setTasks] = useState<Task[]>([])
  const [notes, setNotes] = useState<Note[]>([])
  const [tags, setTags] = useState<string[]>([])
  const [colorMap, setColorMap] = useState<Record<string, string>>({})
  const [tag, setTag] = useState('全部')
  const [keyword, setKeyword] = useState('')
  const [visibleCount, setVisibleCount] = useState(PAGE_SIZE)
  const [loading, setLoading] = useState(true)
  const [openId, setOpenId] = useState('')

  const load = useCallback(async (nextMode: 'task' | 'note') => {
    setLoading(true)
    try {
      if (nextMode === 'task') {
        const [list, cats, colors] = await Promise.all([
          taskRepo.list(),
          categoryRepo.listByType('task'),
          categoryRepo.colorMap(),
        ])
        setTasks(list)
        setTags(cats.map((c) => c.name))
        setColorMap(colors)
      } else {
        const [list, cats, colors] = await Promise.all([
          noteRepo.list(),
          categoryRepo.listByType('note'),
          categoryRepo.colorMap(),
        ])
        setNotes(list)
        setTags(cats.map((c) => c.name))
        setColorMap(colors)
      }
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    } finally {
      setLoading(false)
    }
  }, [])

  useDidShow(() => {
    try {
      const saved = Taro.getStorageSync(TAB_KEY)
      if (saved === 'note' || saved === 'task') {
        setMode(saved)
        setTag('全部')
        setKeyword('')
        setVisibleCount(PAGE_SIZE)
        Taro.removeStorageSync(TAB_KEY)
        load(saved)
        return
      }
    } catch {
      // ignore
    }
    load(mode)
  })

  useEffect(() => {
    setVisibleCount(PAGE_SIZE)
  }, [mode, tag, keyword])

  const onSwitchMode = (next: 'task' | 'note') => {
    if (next === mode) return
    setMode(next)
    setTag('全部')
    setKeyword('')
    setOpenId('')
    setVisibleCount(PAGE_SIZE)
    load(next)
  }

  const onToggle = async (id: string) => {
    try {
      await taskRepo.toggle(id)
      await load('task')
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '更新失败', icon: 'none' })
    }
  }

  const onDeleteTask = async (id: string) => {
    const res = await Taro.showModal({
      title: '删除这个任务？',
      content: '删除后不可恢复。',
    })
    if (!res.confirm) return
    try {
      await taskRepo.remove(id)
      setOpenId('')
      await load('task')
      Taro.showToast({ title: '已删除', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  const onDeleteNote = async (id: string) => {
    const res = await Taro.showModal({
      title: '删除这篇笔记？',
      content: '删除后不可恢复。',
    })
    if (!res.confirm) return
    try {
      await noteRepo.remove(id)
      setOpenId('')
      await load('note')
      Taro.showToast({ title: '已删除', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  const filteredTasks = useMemo(() => {
    const q = keyword.trim().toLowerCase()
    return tasks.filter((item) => {
      if (tag !== '全部') {
        if (tag === '未分类') {
          if (item.category) return false
        } else if (item.category !== tag) {
          return false
        }
      }
      if (!q) return true
      return (
        item.title.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q)
      )
    })
  }, [tasks, tag, keyword])

  const filteredNotes = useMemo(() => {
    const q = keyword.trim().toLowerCase()
    return notes.filter((item) => {
      if (tag !== '全部') {
        if (tag === '未分类') {
          if (item.category) return false
        } else if (item.category !== tag) {
          return false
        }
      }
      if (!q) return true
      return (
        item.title.toLowerCase().includes(q) ||
        item.content.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q)
      )
    })
  }, [notes, tag, keyword])

  const chipList = useMemo(() => {
    const base = ['全部', ...tags]
    const hasEmpty =
      mode === 'task'
        ? tasks.some((t) => !t.category)
        : notes.some((n) => !n.category)
    if (hasEmpty) base.push('未分类')
    return base
  }, [tags, mode, tasks, notes])

  const visibleTasks = useMemo(
    () => filteredTasks.slice(0, visibleCount),
    [filteredTasks, visibleCount],
  )
  const visibleNotes = useMemo(
    () => filteredNotes.slice(0, visibleCount),
    [filteredNotes, visibleCount],
  )

  const filteredLen =
    mode === 'task' ? filteredTasks.length : filteredNotes.length
  const hasMore = visibleCount < filteredLen

  const onLoadMore = () => {
    if (!hasMore || loading) return
    setVisibleCount((n) => Math.min(n + PAGE_SIZE, filteredLen))
  }

  return (
    <View className='workspace-page has-page-header'>
      <AppPageHeader title='事项' />
      <View className='workspace-page__top'>
        <View className='workspace-page__tabs'>
          <Text
            className={`workspace-page__tab ${
              mode === 'task' ? 'is-active' : ''
            }`}
            onClick={() => onSwitchMode('task')}
          >
            任务
          </Text>
          <Text
            className={`workspace-page__tab ${
              mode === 'note' ? 'is-active' : ''
            }`}
            onClick={() => onSwitchMode('note')}
          >
            笔记
          </Text>
        </View>

        <View className='workspace-page__search'>
          <View className='workspace-page__search-icon' aria-hidden>
            <AppIcon icon={Search} size={18} color='#b0b0b0' />
          </View>
          <View className='workspace-page__search-field'>
            <Input
              className='workspace-page__search-input'
              placeholder={
                mode === 'task' ? '搜索任务标题、分类' : '搜索笔记标题、内容'
              }
              placeholderClass='workspace-page__search-ph'
              value={keyword}
              onInput={(e) => setKeyword(e.detail.value)}
              confirmType='search'
            />
          </View>
          {!!keyword && (
            <View
              className='workspace-page__search-clear'
              onClick={() => setKeyword('')}
            >
              <AppIcon icon={X} size={14} color='#8a8a8a' />
            </View>
          )}
        </View>

        <View className='workspace-page__chips'>
          {chipList.map((name) => {
            const active = tag === name
            const color =
              name === '全部'
                ? 'var(--color-accent)'
                : colorMap[name] || '#7a8694'
            const chipStyle =
              name === '全部'
                ? active
                  ? {
                      background: 'var(--color-accent)',
                      color: '#ffffff',
                      boxShadow: 'none',
                    }
                  : undefined
                : active
                  ? {
                      background: color,
                      color: '#ffffff',
                      boxShadow: 'none',
                    }
                  : {
                      background: hexToRgba(String(color), 0.14),
                      color: String(color),
                      boxShadow: `inset 0 0 0 1px ${hexToRgba(String(color), 0.35)}`,
                    }
            return (
              <View
                key={name}
                className={`workspace-page__chip ${active ? 'is-active' : ''}`}
                style={chipStyle}
                onClick={() => setTag(name)}
              >
                {name !== '全部' && (
                  <View
                    className='workspace-page__chip-dot'
                    style={{
                      background: active ? '#ffffff' : String(color),
                    }}
                  />
                )}
                <Text className='workspace-page__chip-text'>{name}</Text>
              </View>
            )
          })}
        </View>
      </View>

      <ScrollView
        className='workspace-page__scroll'
        scrollY
        lowerThreshold={120}
        onScrollToLower={onLoadMore}
      >
        {loading && <Text className='workspace-page__empty'>加载中...</Text>}

        {!loading && mode === 'task' && (
          <>
            {filteredTasks.length === 0 ? (
              <View className='workspace-page__empty-box'>
                <Text className='workspace-page__empty'>
                  {tasks.length === 0 ? '还没有任务' : '没有匹配的任务'}
                </Text>
                <Text className='workspace-page__empty-hint'>
                  {tasks.length === 0
                    ? '点右下角 + 或底部中间菜单添加'
                    : '试试换个分类或清空搜索'}
                </Text>
              </View>
            ) : (
              <View className='workspace-page__list'>
                {visibleTasks.map((task) => (
                  <SwipeDelete
                    key={task.id}
                    className='workspace-page__swipe'
                    open={openId === task.id}
                    onOpenChange={(v) => setOpenId(v ? task.id : '')}
                    onDelete={() => onDeleteTask(task.id)}
                  >
                    <View className='workspace-page__item'>
                      <View
                        className={`workspace-page__check ${
                          task.done ? 'is-done' : ''
                        }`}
                        onClick={() => onToggle(task.id)}
                      >
                        {task.done ? (
                          <AppIcon icon={Check} size={12} color='#fff' />
                        ) : null}
                      </View>
                      <View
                        className='workspace-page__main'
                        onClick={() => {
                          if (openId) {
                            setOpenId('')
                            return
                          }
                          Taro.navigateTo({
                            url: `/pages/tasks/edit?id=${task.id}`,
                          })
                        }}
                      >
                        <Text
                          className={`workspace-page__title ${
                            task.done ? 'is-done' : ''
                          }`}
                        >
                          {task.title}
                        </Text>
                        <View className='workspace-page__meta-row'>
                          <Text
                            className={`workspace-page__priority is-${task.priority}`}
                          >
                            {taskPriorityLabel(task.priority)}
                          </Text>
                          <Text className='workspace-page__meta'>
                            {task.category || '未分类'}
                          </Text>
                          {!!task.dueAt && (
                            <Text
                              className={`workspace-page__due ${
                                !task.done && task.dueAt < todayDate()
                                  ? 'is-overdue'
                                  : ''
                              }`}
                            >
                              {formatDateShort(task.dueAt)}
                            </Text>
                          )}
                        </View>
                      </View>
                    </View>
                  </SwipeDelete>
                ))}
              </View>
            )}
          </>
        )}

        {!loading && mode === 'note' && (
          <>
            {filteredNotes.length === 0 ? (
              <View className='workspace-page__empty-box'>
                <Text className='workspace-page__empty'>
                  {notes.length === 0 ? '还没有笔记' : '没有匹配的笔记'}
                </Text>
                <Text className='workspace-page__empty-hint'>
                  {notes.length === 0
                    ? '点右下角 + 或底部中间菜单添加'
                    : '试试换个分类或清空搜索'}
                </Text>
              </View>
            ) : (
              visibleNotes.map((note) => (
                <SwipeDelete
                  key={note.id}
                  className='workspace-page__note-swipe'
                  open={openId === note.id}
                  onOpenChange={(v) => setOpenId(v ? note.id : '')}
                  onDelete={() => onDeleteNote(note.id)}
                >
                  <View
                    className='workspace-page__note'
                    onClick={() => {
                      if (openId) {
                        setOpenId('')
                        return
                      }
                      Taro.navigateTo({
                        url: `/pages/notes/edit?id=${note.id}`,
                      })
                    }}
                  >
                    {!!note.category && (
                      <Text className='workspace-page__note-cat'>
                        {note.category}
                      </Text>
                    )}
                    <Text className='workspace-page__title'>
                      {note.title || '无标题'}
                    </Text>
                    <Text className='workspace-page__summary'>
                      {note.content || '暂无内容'}
                    </Text>
                    <Text className='workspace-page__meta'>
                      {new Date(note.updatedAt).toLocaleString('zh-CN')}
                    </Text>
                  </View>
                </SwipeDelete>
              ))
            )}
          </>
        )}

        {!loading && filteredLen > 0 && (
          <Text className='workspace-page__foot'>
            {hasMore ? '上拉加载更多' : '没有更多了'}
          </Text>
        )}
      </ScrollView>

      <PrimaryFab
        onClick={() =>
          Taro.navigateTo({
            url: mode === 'task' ? '/pages/tasks/edit' : '/pages/notes/edit',
          })
        }
      />
      <AppDock />
    </View>
  )
}
