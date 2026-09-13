import { useCallback, useEffect, useMemo, useState } from 'react'
import { Input, Picker, Text, Textarea, View } from '@tarojs/components'
import Taro, { useDidShow, useRouter } from '@tarojs/taro'
import { AppButton } from '../../components/AppButton'
import {
  DEFAULT_PAYMENT_METHOD,
  PAYMENT_METHODS,
  type TxType,
} from '../../domain/types'
import { AppPageHeader } from '../../components/AppPageHeader'
import { categoryRepo } from '../../repositories/categoryRepo'
import { transactionRepo } from '../../repositories/transactionRepo'
import { todayDate } from '../../utils/date'
import './edit.scss'

export default function LedgerEditPage() {
  const router = useRouter()
  const id = router.params.id
  const [type, setType] = useState<TxType>('expense')
  const [amount, setAmount] = useState('')
  const [category, setCategory] = useState('')
  const [categories, setCategories] = useState<string[]>([])
  const [paymentMethod, setPaymentMethod] = useState(DEFAULT_PAYMENT_METHOD)
  const [note, setNote] = useState('')
  const [occurredAt, setOccurredAt] = useState(
    router.params.date || todayDate(),
  )
  const [saving, setSaving] = useState(false)

  const loadCategories = useCallback(async (txType: TxType) => {
    try {
      const rows = await categoryRepo.listByType(txType)
      const names = rows.map((r) => r.name)
      setCategories(names)
      return names
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '分类加载失败', icon: 'none' })
      return []
    }
  }, [])

  useDidShow(() => {
    loadCategories(type)
  })

  useEffect(() => {
    ;(async () => {
      const names = await loadCategories(type)
      setCategory((prev) => {
        if (prev && names.includes(prev)) return prev
        return names[0] || ''
      })
    })()
  }, [type, loadCategories])

  useEffect(() => {
    if (!id) return
    ;(async () => {
      try {
        const row = await transactionRepo.get(id)
        if (!row) {
          Taro.showToast({ title: '记录不存在', icon: 'none' })
          return
        }
        setType(row.type)
        setAmount(String(row.amount))
        setCategory(row.category)
        setPaymentMethod(row.paymentMethod || DEFAULT_PAYMENT_METHOD)
        setNote(row.note)
        setOccurredAt(row.occurredAt)
      } catch (e: any) {
        Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
      }
    })()
  }, [id])

  const pickerValue = useMemo(
    () => Math.max(0, categories.indexOf(category)),
    [categories, category],
  )

  const onSave = async () => {
    const value = Number(amount)
    if (!amount || Number.isNaN(value) || value <= 0) {
      Taro.showToast({ title: '请输入有效金额', icon: 'none' })
      return
    }
    if (!category) {
      Taro.showToast({ title: '请选择分类', icon: 'none' })
      return
    }
    setSaving(true)
    try {
      await transactionRepo.save({
        id,
        type,
        amount: value,
        category,
        note,
        paymentMethod,
        occurredAt,
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
    const res = await Taro.showModal({ title: '删除这笔流水？' })
    if (!res.confirm) return
    try {
      await transactionRepo.remove(id)
      Taro.showToast({ title: '已删除', icon: 'success' })
      setTimeout(() => Taro.navigateBack(), 400)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  return (
    <View className='ledger-edit has-page-header'>
      <AppPageHeader title={id ? '编辑流水' : '记一笔'} showBack />
      <View className='ledger-edit__tabs'>
        <Text
          className={`ledger-edit__tab ${type === 'expense' ? 'is-active expense' : ''}`}
          onClick={() => setType('expense')}
        >
          支出
        </Text>
        <Text
          className={`ledger-edit__tab ${type === 'income' ? 'is-active income' : ''}`}
          onClick={() => setType('income')}
        >
          收入
        </Text>
      </View>

      <View className='ledger-edit__field'>
        <Text className='ledger-edit__label'>金额</Text>
        <Input
          className='ledger-edit__input'
          type='digit'
          placeholder='0.00'
          value={amount}
          onInput={(e) => setAmount(e.detail.value)}
        />
      </View>

      <View className='ledger-edit__field'>
        <Text className='ledger-edit__label'>分类</Text>
        <Picker
          mode='selector'
          range={categories}
          value={pickerValue}
          onChange={(e) => setCategory(categories[Number(e.detail.value)])}
        >
          <View className='ledger-edit__picker'>{category || '请选择'}</View>
        </Picker>
        <Text
          className='ledger-edit__manage'
          onClick={() => Taro.navigateTo({ url: '/pages/categories/index' })}
        >
          管理分类
        </Text>
      </View>

      <View className='ledger-edit__field'>
        <Text className='ledger-edit__label'>
          {type === 'income' ? '到账方式' : '支付方式'}
        </Text>
        <View className='ledger-edit__pay-list'>
          {PAYMENT_METHODS.map((name) => (
            <Text
              key={name}
              className={`ledger-edit__pay-item ${
                paymentMethod === name ? 'is-active' : ''
              }`}
              onClick={() => setPaymentMethod(name)}
            >
              {name}
            </Text>
          ))}
        </View>
      </View>

      <View className='ledger-edit__field'>
        <Text className='ledger-edit__label'>日期</Text>
        <Picker
          mode='date'
          value={occurredAt}
          onChange={(e) => setOccurredAt(e.detail.value)}
        >
          <View className='ledger-edit__picker'>{occurredAt}</View>
        </Picker>
      </View>

      <View className='ledger-edit__field'>
        <Text className='ledger-edit__label'>备注</Text>
        <Textarea
          className='ledger-edit__textarea'
          placeholder='写点什么…'
          value={note}
          onInput={(e) => setNote(e.detail.value)}
        />
      </View>

      <AppButton
        className='ledger-edit__save'
        loading={saving}
        onClick={onSave}
      >
        保存
      </AppButton>
      {!!id && (
        <AppButton
          className='ledger-edit__delete'
          variant='danger'
          onClick={onDelete}
        >
          删除
        </AppButton>
      )}
    </View>
  )
}
