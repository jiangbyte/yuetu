import { useEffect, useState } from 'react'
import { Input, Picker, Switch, Text, View } from '@tarojs/components'
import Taro, { useRouter } from '@tarojs/taro'
import { AppButton } from '../../components/AppButton'
import { AppPageHeader } from '../../components/AppPageHeader'
import { SuggestCategory } from '../../components/SuggestCategory'
import {
  TASK_PRIORITIES,
  type TaskPriority,
} from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import { taskRepo } from '../../repositories/taskRepo'
import { todayDate } from '../../utils/date'
import './edit.scss'

export default function TaskEditPage() {
  const router = useRouter()
  const id = router.params.id
  const [title, setTitle] = useState('')
  const [category, setCategory] = useState('')
  const [done, setDone] = useState(false)
  const [dueAt, setDueAt] = useState(router.params.due || todayDate())
  const [priority, setPriority] = useState<TaskPriority>('medium')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!id) return
    ;(async () => {
      try {
        const row = await taskRepo.get(id)
        if (!row) return
        setTitle(row.title)
        setCategory(row.category || '')
        setDone(!!row.done)
        setDueAt(row.dueAt || '')
        setPriority(row.priority || 'medium')
      } catch (e: any) {
        Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
      }
    })()
  }, [id])

  const onSave = async () => {
    if (!title.trim()) {
      Taro.showToast({ title: '请填写任务标题', icon: 'none' })
      return
    }
    setSaving(true)
    try {
      const cat = await categoryRepo.ensure('task', category)
      await taskRepo.save({
        id,
        title: title.trim(),
        category: cat,
        done: done ? 1 : 0,
        dueAt: dueAt || null,
        priority,
      })
      Taro.showToast({ title: '已保存', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 400)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '保存失败', icon: 'none' })
    } finally {
      setSaving(false)
    }
  }

  const onDelete = async () => {
    if (!id) return
    const res = await Taro.showModal({ title: '删除这个任务？' })
    if (!res.confirm) return
    try {
      await taskRepo.remove(id)
      Taro.navigateBack()
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  return (
    <View className='task-edit has-page-header'>
      <AppPageHeader title={id ? '编辑任务' : '新任务'} showBack />
      <View className='task-edit__field'>
        <Text className='task-edit__label'>标题</Text>
        <Input
          className='task-edit__input'
          placeholder='要做什么？'
          value={title}
          onInput={(e) => setTitle(e.detail.value)}
        />
      </View>
      <View className='task-edit__field'>
        <Text className='task-edit__label'>分类</Text>
        <SuggestCategory
          kind='task'
          value={category}
          onChange={setCategory}
          placeholder='输入或选择任务分类'
        />
      </View>
      <View className='task-edit__field'>
        <Text className='task-edit__label'>优先级</Text>
        <View className='task-edit__priority'>
          {TASK_PRIORITIES.map((item) => (
            <Text
              key={item.key}
              className={`task-edit__priority-item is-${item.key} ${
                priority === item.key ? 'is-active' : ''
              }`}
              onClick={() => setPriority(item.key)}
            >
              {item.label}
            </Text>
          ))}
        </View>
      </View>
      <View className='task-edit__field'>
        <Text className='task-edit__label'>截止日期</Text>
        <Picker
          mode='date'
          value={dueAt || todayDate()}
          onChange={(e) => setDueAt(e.detail.value)}
        >
          <View className='task-edit__picker'>{dueAt || '不设置'}</View>
        </Picker>
        {!!dueAt && (
          <Text className='task-edit__clear' onClick={() => setDueAt('')}>
            清除日期
          </Text>
        )}
      </View>
      <View className='task-edit__field task-edit__row'>
        <Text className='task-edit__label'>已完成</Text>
        <Switch checked={done} onChange={(e) => setDone(!!e.detail.value)} />
      </View>
      <AppButton className='task-edit__save' loading={saving} onClick={onSave}>
        保存
      </AppButton>
      {!!id && (
        <AppButton
          className='task-edit__delete'
          variant='danger'
          onClick={onDelete}
        >
          删除
        </AppButton>
      )}
    </View>
  )
}
