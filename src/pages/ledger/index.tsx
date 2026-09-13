import { useCallback, useEffect, useMemo, useState } from 'react'
import { Input, ScrollView, Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { Search, X } from 'lucide-react'
import { AmountText } from '../../components/AmountText'
import { AppDock } from '../../components/AppDock'
import { AppIcon } from '../../components/AppIcon'
import { AppPageHeader } from '../../components/AppPageHeader'
import { CategoryIcon } from '../../components/CategoryIcon'
import { DaySection } from '../../components/DaySection'
import { PrimaryFab } from '../../components/PrimaryFab'
import { SwipeDelete } from '../../components/SwipeDelete'
import type { MonthSummary, Transaction, TxType } from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import {
  groupByDay,
  transactionRepo,
} from '../../repositories/transactionRepo'
import {
  currentYearMonth,
  formatYearMonthShort,
  shiftYearMonth,
  todayDate,
} from '../../utils/date'
import { formatMoney } from '../../utils/money'
import './index.scss'

type Direction = 'all' | TxType

const DIRECTION_TABS: Array<{ key: Direction; label: string }> = [
  { key: 'all', label: '全部' },
  { key: 'expense', label: '支出' },
  { key: 'income', label: '收入' },
]

const PAGE_SIZE = 20

export default function LedgerPage() {
  const [ym, setYm] = useState(currentYearMonth())
  const [summary, setSummary] = useState<MonthSummary>({
    income: 0,
    expense: 0,
    balance: 0,
  })
  const [todayExpense, setTodayExpense] = useState(0)
  const [list, setList] = useState<Transaction[]>([])
  const [expenseTags, setExpenseTags] = useState<string[]>([])
  const [incomeTags, setIncomeTags] = useState<string[]>([])
  const [colorMap, setColorMap] = useState<Record<string, string>>({})
  const [direction, setDirection] = useState<Direction>('all')
  const [tag, setTag] = useState('全部')
  const [keyword, setKeyword] = useState('')
  const [visibleCount, setVisibleCount] = useState(PAGE_SIZE)
  const [loading, setLoading] = useState(true)
  const [openId, setOpenId] = useState('')

  const load = useCallback(async () => {
    setLoading(true)
    try {
      // 1. 并行拉取月汇总、流水、分类与今日支出
      // 2. 分类按收支两侧缓存，供 Tab 切换时立刻换 tag 列表
      const [sum, monthList, colors, todayList, expenseCats, incomeCats] =
        await Promise.all([
          transactionRepo.monthSummary(ym),
          transactionRepo.listByMonth(ym),
          categoryRepo.colorMap(),
          transactionRepo.listByDate(todayDate()),
          categoryRepo.listByType('expense'),
          categoryRepo.listByType('income'),
        ])
      setSummary(sum)
      setList(monthList)
      setColorMap(colors)
      setExpenseTags(expenseCats.map((c) => c.name))
      setIncomeTags(incomeCats.map((c) => c.name))
      setTodayExpense(
        todayList
          .filter((i) => i.type === 'expense')
          .reduce((s, i) => s + i.amount, 0),
      )
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    } finally {
      setLoading(false)
    }
  }, [ym])

  useDidShow(() => {
    load()
  })

  useEffect(() => {
    load()
  }, [load])

  // 筛选条件变化时从首页重新分页
  useEffect(() => {
    setVisibleCount(PAGE_SIZE)
  }, [direction, tag, keyword, ym])

  const onSwitchDirection = (next: Direction) => {
    if (next === direction) return
    setDirection(next)
    setTag('全部')
    setOpenId('')
  }

  const chipList = useMemo(() => {
    const fromRepo =
      direction === 'expense'
        ? expenseTags
        : direction === 'income'
          ? incomeTags
          : Array.from(new Set([...expenseTags, ...incomeTags]))
    const fromData = list
      .filter((item) => direction === 'all' || item.type === direction)
      .map((item) => item.category)
      .filter(Boolean)
    return ['全部', ...Array.from(new Set([...fromRepo, ...fromData]))]
  }, [direction, expenseTags, incomeTags, list])

  const filteredList = useMemo(() => {
    const q = keyword.trim().toLowerCase()
    return list.filter((item) => {
      if (direction !== 'all' && item.type !== direction) return false
      if (tag !== '全部' && item.category !== tag) return false
      if (!q) return true
      return (
        item.category.toLowerCase().includes(q) ||
        item.note.toLowerCase().includes(q) ||
        item.paymentMethod.toLowerCase().includes(q)
      )
    })
  }, [list, direction, tag, keyword])

  const visibleList = useMemo(
    () => filteredList.slice(0, visibleCount),
    [filteredList, visibleCount],
  )
  const groups = useMemo(() => groupByDay(visibleList), [visibleList])
  const hasMore = visibleCount < filteredList.length

  const onLoadMore = () => {
    if (!hasMore || loading) return
    setVisibleCount((n) => Math.min(n + PAGE_SIZE, filteredList.length))
  }

  const onDeleteTx = async (id: string) => {
    const res = await Taro.showModal({
      title: '删除这笔流水？',
      content: '删除后不可恢复。',
    })
    if (!res.confirm) return
    try {
      await transactionRepo.remove(id)
      setOpenId('')
      await load()
      Taro.showToast({ title: '已删除', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '删除失败', icon: 'none' })
    }
  }

  const emptyHint = (() => {
    if (loading) return '加载中...'
    if (list.length === 0) return '本月还没有流水'
    if (filteredList.length === 0) return '没有符合筛选的流水'
    return ''
  })()

  return (
    <View className='ledger-page has-page-header'>
      <AppPageHeader title='流水' />
      <View className='ledger-page__top'>
        <View className='ledger-page__hero'>
          <View className='ledger-page__hero-top'>
            <View className='ledger-page__month'>
              <Text
                className='ledger-page__arrow'
                onClick={() => {
                  setYm(shiftYearMonth(ym, -1))
                  setTag('全部')
                  setKeyword('')
                }}
              >
                ‹
              </Text>
              <Text className='ledger-page__ym'>
                {formatYearMonthShort(ym)}
              </Text>
              <Text
                className='ledger-page__arrow'
                onClick={() => {
                  setYm(shiftYearMonth(ym, 1))
                  setTag('全部')
                  setKeyword('')
                }}
              >
                ›
              </Text>
            </View>
            <Text
              className='ledger-page__report'
              onClick={() => Taro.navigateTo({ url: '/pages/reports/index' })}
            >
              报表
            </Text>
          </View>

          <Text className='ledger-page__hint'>本月支出</Text>
          <View className='ledger-page__main-amount'>
            <AmountText value={summary.expense} size='lg' />
          </View>

          <View className='ledger-page__stats'>
            <View className='ledger-page__stat'>
              <Text className='ledger-page__stat-label'>今日支出</Text>
              <Text className='ledger-page__stat-value'>
                {formatMoney(todayExpense)}
              </Text>
            </View>
            <View className='ledger-page__stat'>
              <Text className='ledger-page__stat-label'>本月收入</Text>
              <Text className='ledger-page__stat-value is-income'>
                {formatMoney(summary.income)}
              </Text>
            </View>
            <View className='ledger-page__stat'>
              <Text className='ledger-page__stat-label'>本月结余</Text>
              <Text
                className={`ledger-page__stat-value ${
                  summary.balance >= 0 ? 'is-income' : ''
                }`}
              >
                {formatMoney(summary.balance)}
              </Text>
            </View>
          </View>
        </View>

        <View className='ledger-page__tabs'>
          {DIRECTION_TABS.map((tab) => (
            <Text
              key={tab.key}
              className={`ledger-page__tab ${
                direction === tab.key ? 'is-active' : ''
              }`}
              onClick={() => onSwitchDirection(tab.key)}
            >
              {tab.label}
            </Text>
          ))}
        </View>

        <View className='ledger-page__search'>
          <View className='ledger-page__search-icon' aria-hidden>
            <AppIcon icon={Search} size={18} color='#b0b0b0' />
          </View>
          <View className='ledger-page__search-field'>
            <Input
              className='ledger-page__search-input'
              placeholder='搜索分类、备注、支付方式'
              placeholderClass='ledger-page__search-ph'
              value={keyword}
              onInput={(e) => setKeyword(e.detail.value)}
              confirmType='search'
            />
          </View>
          {!!keyword && (
            <View
              className='ledger-page__search-clear'
              onClick={() => setKeyword('')}
            >
              <AppIcon icon={X} size={14} color='#8a8a8a' />
            </View>
          )}
        </View>

        <View className='ledger-page__chips'>
          {chipList.map((name) => (
            <Text
              key={name}
              className={`ledger-page__chip ${tag === name ? 'is-active' : ''}`}
              onClick={() => setTag(name)}
            >
              {name}
            </Text>
          ))}
        </View>

        <Text className='ledger-page__list-title'>账单</Text>
      </View>

      <ScrollView
        className='ledger-page__scroll'
        scrollY
        lowerThreshold={120}
        onScrollToLower={onLoadMore}
      >
        {!!emptyHint && (
          <Text className='ledger-page__empty'>{emptyHint}</Text>
        )}
        {groups.map((g) => {
          const income = g.items
            .filter((i) => i.type === 'income')
            .reduce((s, i) => s + i.amount, 0)
          const expense = g.items
            .filter((i) => i.type === 'expense')
            .reduce((s, i) => s + i.amount, 0)
          return (
            <DaySection
              key={g.date}
              date={g.date}
              income={income}
              expense={expense}
            >
              {g.items.map((item) => (
                <SwipeDelete
                  key={item.id}
                  className='ledger-page__swipe'
                  open={openId === item.id}
                  onOpenChange={(v) => setOpenId(v ? item.id : '')}
                  onDelete={() => onDeleteTx(item.id)}
                >
                  <View
                    className='ledger-page__item'
                    onClick={() => {
                      if (openId) {
                        setOpenId('')
                        return
                      }
                      Taro.navigateTo({
                        url: `/pages/ledger/edit?id=${item.id}`,
                      })
                    }}
                  >
                    <CategoryIcon
                      category={item.category}
                      color={colorMap[item.category]}
                    />
                    <View className='ledger-page__item-main'>
                      <Text className='ledger-page__item-title'>
                        {item.category}
                        {item.note ? ` · ${item.note}` : ''}
                      </Text>
                      <Text className='ledger-page__item-note'>
                        {item.type === 'income' ? '收入' : '支出'}
                        {item.paymentMethod
                          ? ` · ${item.paymentMethod}`
                          : ''}
                      </Text>
                    </View>
                    <AmountText
                      value={item.amount}
                      type={item.type === 'income' ? 'income' : 'expense'}
                      signed
                      size='md'
                    />
                  </View>
                </SwipeDelete>
              ))}
            </DaySection>
          )
        })}

        {!emptyHint && (
          <Text className='ledger-page__foot'>
            {hasMore
              ? '上拉加载更多'
              : filteredList.length > 0
                ? '没有更多了'
                : ''}
          </Text>
        )}
      </ScrollView>

      <PrimaryFab
        onClick={() => Taro.navigateTo({ url: '/pages/ledger/edit' })}
      />
      <AppDock />
    </View>
  )
}
