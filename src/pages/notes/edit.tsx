import { useEffect, useState } from 'react'
import { Input, Textarea, Text, View } from '@tarojs/components'
import Taro, { useRouter } from '@tarojs/taro'
import { AppButton } from '../../components/AppButton'
import { AppPageHeader } from '../../components/AppPageHeader'
import { SuggestCategory } from '../../components/SuggestCategory'
import { categoryRepo } from '../../repositories/categoryRepo'
import { noteRepo } from '../../repositories/noteRepo'
import './edit.scss'

export default function NoteEditPage() {
  const router = useRouter()
  const id = router.params.id
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [category, setCategory] = useState('')
  const [saving, setSaving] = useState(false)

  useEffect(() => {
    if (!id) return
    ;(async () => {
      try {
        const row = await noteRepo.get(id)
        if (!row) return
        setTitle(row.title)
        setContent(row.content)
        setCategory(row.category || '')
      } catch (e: any) {
        Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
      }
    })()
  }, [id])

  const onSave = async () => {
    setSaving(true)
    try {
      const cat = await categoryRepo.ensure('note', category)
      await noteRepo.save({
        id,
        title: title.trim() || '无标题',
        content,
        category: cat,
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
    const res = await Taro.showModal({ title: '删除这篇笔记？' })
    if (!res.confirm) return
    try {
      await noteRepo.remove(id)
      Taro.navigateBack()
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  return (
    <View className='note-edit has-page-header'>
      <AppPageHeader title={id ? '编辑笔记' : '写笔记'} showBack />
      <View className='note-edit__field'>
        <Text className='note-edit__label'>分类</Text>
        <SuggestCategory
          kind='note'
          value={category}
          onChange={setCategory}
          placeholder='输入或选择笔记分类'
        />
      </View>
      <View className='note-edit__field'>
        <Text className='note-edit__label'>标题</Text>
        <Input
          className='note-edit__input'
          placeholder='无标题也可以…'
          value={title}
          onInput={(e) => setTitle(e.detail.value)}
        />
      </View>
      <View className='note-edit__field note-edit__field--content'>
        <Text className='note-edit__label'>正文</Text>
        <Textarea
          className='note-edit__content'
          placeholder='开始写点什么…'
          value={content}
          maxlength={10000}
          showConfirmBar={false}
          disableDefaultPadding
          onInput={(e) => setContent(e.detail.value)}
        />
      </View>
      <AppButton className='note-edit__save' loading={saving} onClick={onSave}>
        保存
      </AppButton>
      {!!id && (
        <AppButton
          className='note-edit__delete'
          variant='danger'
          onClick={onDelete}
        >
          删除
        </AppButton>
      )}
    </View>
  )
}
