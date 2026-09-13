import { useCallback, useEffect, useState } from 'react'
import { Input, Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { Plus } from 'lucide-react'
import { AppButton } from '../../components/AppButton'
import { AppCard } from '../../components/AppCard'
import { AppIcon } from '../../components/AppIcon'
import { AppPageHeader } from '../../components/AppPageHeader'
import { CategoryIcon } from '../../components/CategoryIcon'
import {
  CATEGORY_COLOR_PALETTE,
  type Category,
  type CategoryKind,
} from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import './index.scss'

const KIND_TABS: Array<{ key: CategoryKind; label: string }> = [
  { key: 'expense', label: '支出' },
  { key: 'income', label: '收入' },
  { key: 'note', label: '笔记' },
  { key: 'task', label: '任务' },
]

export default function CategoriesPage() {
  const [type, setType] = useState<CategoryKind>('expense')
  const [list, setList] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [name, setName] = useState('')
  const [color, setColor] = useState(CATEGORY_COLOR_PALETTE[0])
  const [saving, setSaving] = useState(false)

  const load = useCallback(async () => {
    setLoading(true)
    try {
      setList(await categoryRepo.listByType(type))
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    } finally {
      setLoading(false)
    }
  }, [type])

  useDidShow(() => {
    load()
  })

  useEffect(() => {
    load()
  }, [load])

  const resetForm = () => {
    setEditingId(null)
    setName('')
    setColor(CATEGORY_COLOR_PALETTE[0])
  }

  const onStartCreate = () => {
    setEditingId('new')
    setName('')
    setColor(CATEGORY_COLOR_PALETTE[0])
  }

  const onStartEdit = (item: Category) => {
    setEditingId(item.id)
    setName(item.name)
    setColor(item.color)
  }

  const onSave = async () => {
    if (!name.trim()) {
      Taro.showToast({ title: '请输入分类名称', icon: 'none' })
      return
    }
    setSaving(true)
    try {
      if (editingId === 'new') {
        await categoryRepo.create({ type, name, color })
      } else if (editingId) {
        await categoryRepo.update({ id: editingId, name, color })
      }
      resetForm()
      await load()
      Taro.showToast({ title: '已保存', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '保存失败', icon: 'none' })
    } finally {
      setSaving(false)
    }
  }

  const onDelete = async (item: Category) => {
    const res = await Taro.showModal({
      title: `删除「${item.name}」？`,
      content: '若仍有内容使用该分类将无法删除。',
    })
    if (!res.confirm) return
    try {
      await categoryRepo.remove(item.id)
      if (editingId === item.id) resetForm()
      await load()
      Taro.showToast({ title: '已删除', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  return (
    <View className='categories-page has-page-header'>
      <AppPageHeader title='分类管理' showBack />
      <View className='categories-page__tabs'>
        {KIND_TABS.map((tab) => (
          <Text
            key={tab.key}
            className={`categories-page__tab ${
              type === tab.key ? 'is-active' : ''
            }`}
            onClick={() => {
              resetForm()
              setType(tab.key)
            }}
          >
            {tab.label}
          </Text>
        ))}
      </View>

      {editingId && (
        <AppCard className='categories-page__form'>
          <Text className='categories-page__form-title'>
            {editingId === 'new' ? '新建分类' : '编辑分类'}
          </Text>
          <Input
            className='categories-page__input'
            placeholder='分类名称'
            maxlength={12}
            value={name}
            onInput={(e) => setName(e.detail.value)}
          />
          <Text className='categories-page__color-label'>颜色</Text>
          <View className='categories-page__palette'>
            {CATEGORY_COLOR_PALETTE.map((c) => (
              <View
                key={c}
                className={`categories-page__swatch ${color === c ? 'is-active' : ''}`}
                style={{ background: c }}
                onClick={() => setColor(c)}
              />
            ))}
          </View>
          <View className='categories-page__form-actions'>
            <AppButton
              className='categories-page__cancel'
              variant='secondary'
              size='mini'
              block={false}
              onClick={resetForm}
            >
              取消
            </AppButton>
            <AppButton
              className='categories-page__save'
              size='mini'
              block={false}
              loading={saving}
              onClick={onSave}
            >
              保存
            </AppButton>
          </View>
        </AppCard>
      )}

      <AppCard className='categories-page__list'>
        {loading && (
          <Text className='categories-page__empty'>加载中...</Text>
        )}
        {!loading && list.length === 0 && (
          <Text className='categories-page__empty'>暂无分类</Text>
        )}
        {list.map((item) => (
          <View key={item.id} className='categories-page__item'>
            <CategoryIcon category={item.name} color={item.color} />
            <Text className='categories-page__name'>{item.name}</Text>
            <Text
              className='categories-page__action'
              onClick={() => onStartEdit(item)}
            >
              编辑
            </Text>
            <Text
              className='categories-page__action is-danger'
              onClick={() => onDelete(item)}
            >
              删除
            </Text>
          </View>
        ))}
      </AppCard>

      {!editingId && (
        <View className='categories-page__add' onClick={onStartCreate}>
          <AppIcon icon={Plus} size={14} color='#1a1a1a' />
          <Text className='categories-page__add-text'>添加分类</Text>
        </View>
      )}
    </View>
  )
}
