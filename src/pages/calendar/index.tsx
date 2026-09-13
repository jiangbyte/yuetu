import { useCallback, useMemo, useState } from 'react'
import { Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import { Plus } from 'lucide-react'
import { AmountText } from '../../components/AmountText'
import { AppDock } from '../../components/AppDock'
import { AppIcon } from '../../components/AppIcon'
import { AppPageHeader } from '../../components/AppPageHeader'
import { CategoryIcon } from '../../components/CategoryIcon'
import type { Task, Transaction } from '../../domain/types'
import { taskPriorityLabel } from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import { taskRepo } from '../../repositories/taskRepo'
import { transactionRepo } from '../../repositories/transactionRepo'
import {
  buildMonthGrid,
  currentYearMonth,
  formatDayLabel,
  formatYearMonth,
  shiftYearMonth,
  todayDate,
  yearMonthOf,
} from '../../utils/date'
import './index.scss'

const WEEK = ['日', '一', '二', '三', '四', '五', '六']

export default function CalendarPage() {
  const [ym, setYm] = useState(currentYearMonth())
  const [selected, setSelected] = useState(todayDate())
  const [txMarks, setTxMarks] = useState<
    Record<string, { income: number; expense: number; count: number }>
  >({})
  const [taskMarks, setTaskMarks] = useState<Record<string, number>>({})
  const [txs, setTxs] = useState<Transaction[]>([])
  const [tasks, setTasks] = useState<Task[]>([])
  const [colorMap, setColorMap] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(true)

  const cells = useMemo(() => buildMonthGrid(ym), [ym])

  const loadMonth = useCallback(async (month: string) => {
    try {
      const [txm, tkm, colors] = await Promise.all([
        transactionRepo.dayMarksByMonth(month),
        taskRepo.dueMarksByMonth(month),
        categoryRepo.colorMap(),
      ])
      setTxMarks(txm)
      setTaskMarks(tkm)
      setColorMap(colors)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    }
  }, [])

  const loadDay = useCallback(async (date: string) => {
    setLoading(true)
    try {
      const [dayTx, dayTasks] = await Promise.all([
        transactionRepo.listByDate(date),
        taskRepo.listByDueDate(date),
      ])
      setTxs(dayTx)
      setTasks(dayTasks)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    } finally {
      setLoading(false)
    }
  }, [])

  useDidShow(() => {
    loadMonth(ym)
    loadDay(selected)
  })

  const onSelectMonth = (delta: number) => {
    const next = shiftYearMonth(ym, delta)
    setYm(next)
    loadMonth(next)
    // 切月时选中该月同一天或月末
    const day = Number(selected.slice(8, 10))
    const [y, m] = next.split('-').map(Number)
    const last = new Date(y, m, 0).getDate()
    const nextDate = `${next}-${String(Math.min(day, last)).padStart(2, '0')}`
    setSelected(nextDate)
    loadDay(nextDate)
  }

  const onSelectDay = (date: string, inMonth: boolean) => {
    setSelected(date)
    if (!inMonth) {
      const nextYm = yearMonthOf(date)
      setYm(nextYm)
      loadMonth(nextYm)
    }
    loadDay(date)
  }

  const onToggleTask = async (id: string) => {
    try {
      await taskRepo.toggle(id)
      await loadDay(selected)
      await loadMonth(ym)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '更新失败', icon: 'none' })
    }
  }

  const dayExpense = txs
    .filter((t) => t.type === 'expense')
    .reduce((s, t) => s + t.amount, 0)
  const dayIncome = txs
    .filter((t) => t.type === 'income')
    .reduce((s, t) => s + t.amount, 0)

  return (
    <View className='calendar-page has-page-header'>
      <AppPageHeader title='日历' />
      <View className='calendar-page__head'>
        <View className='calendar-page__month'>
          <Text className='calendar-page__arrow' onClick={() => onSelectMonth(-1)}>
            ‹
          </Text>
          <Text className='calendar-page__ym'>{formatYearMonth(ym)}</Text>
          <Text className='calendar-page__arrow' onClick={() => onSelectMonth(1)}>
            ›
          </Text>
        </View>
        <Text
          className='calendar-page__today-btn'
          onClick={() => {
            const t = todayDate()
            setYm(yearMonthOf(t))
            setSelected(t)
            loadMonth(yearMonthOf(t))
            loadDay(t)
          }}
        >
          今天
        </Text>
      </View>

      <View className='calendar-page__week'>
        {WEEK.map((w) => (
          <Text key={w} className='calendar-page__weekday'>
            {w}
          </Text>
        ))}
      </View>

      <View className='calendar-page__grid'>
        {cells.map((cell) => {
          const selectedDay = cell.date === selected
          const hasTx = !!txMarks[cell.date]
          const hasTask = !!taskMarks[cell.date]
          return (
            <View
              key={cell.date}
              className={`calendar-page__cell ${
                cell.inMonth ? '' : 'is-out'
              } ${selectedDay ? 'is-selected' : ''} ${
                cell.isToday && !selectedDay ? 'is-today' : ''
              }`}
              onClick={() => onSelectDay(cell.date, cell.inMonth)}
            >
              <View className='calendar-page__day-num'>
                <Text>{cell.day}</Text>
              </View>
              <View className='calendar-page__dots'>
                {hasTx && <View className='calendar-page__dot is-tx' />}
                {hasTask && <View className='calendar-page__dot is-task' />}
              </View>
            </View>
          )
        })}
      </View>

      <View className='calendar-page__detail'>
        <View className='calendar-page__detail-head'>
          <Text className='calendar-page__detail-date'>
            {formatDayLabel(selected)}
          </Text>
          <Text className='calendar-page__detail-sum'>
            支 {dayExpense.toFixed(2)} · 收 {dayIncome.toFixed(2)}
          </Text>
        </View>

        <View className='calendar-page__actions'>
          <View
            className='calendar-page__action'
            onClick={() =>
              Taro.navigateTo({
                url: `/pages/ledger/edit?date=${selected}`,
              })
            }
          >
            <AppIcon icon={Plus} size={14} color='#1a1a1a' />
            <Text className='calendar-page__action-text'>记一笔</Text>
          </View>
          <View
            className='calendar-page__action'
            onClick={() =>
              Taro.navigateTo({
                url: `/pages/tasks/edit?due=${selected}`,
              })
            }
          >
            <AppIcon icon={Plus} size={14} color='#1a1a1a' />
            <Text className='calendar-page__action-text'>新任务</Text>
          </View>
        </View>

        {loading && <Text className='calendar-page__empty'>加载中...</Text>}

        {!loading && (
          <>
            <Text className='calendar-page__section'>流水</Text>
            {txs.length === 0 && (
              <Text className='calendar-page__empty-inline'>当日暂无流水</Text>
            )}
            {txs.map((item) => (
              <View
                key={item.id}
                className='calendar-page__tx'
                onClick={() =>
                  Taro.navigateTo({
                    url: `/pages/ledger/edit?id=${item.id}`,
                  })
                }
              >
                <CategoryIcon
                  category={item.category}
                  color={colorMap[item.category]}
                />
                <View className='calendar-page__tx-main'>
                  <Text className='calendar-page__tx-title'>{item.category}</Text>
                  <Text className='calendar-page__tx-note'>
                    {item.type === 'income' ? '收入' : '支出'}
                    {item.paymentMethod ? ` · ${item.paymentMethod}` : ''}
                    {item.note ? ` · ${item.note}` : ''}
                  </Text>
                </View>
                <AmountText
                  value={item.amount}
                  type={item.type === 'income' ? 'income' : 'expense'}
                  signed
                  size='md'
                />
              </View>
            ))}

            <Text className='calendar-page__section'>任务</Text>
            {tasks.length === 0 && (
              <Text className='calendar-page__empty-inline'>当日暂无任务</Text>
            )}
            {tasks.map((task) => (
              <View key={task.id} className='calendar-page__task'>
                <View className='calendar-page__task-bar' />
                <View
                  className={`calendar-page__check ${task.done ? 'is-done' : ''}`}
                  onClick={() => onToggleTask(task.id)}
                >
                  {task.done ? '✓' : ''}
                </View>
                <View
                  className='calendar-page__task-main'
                  onClick={() =>
                    Taro.navigateTo({
                      url: `/pages/tasks/edit?id=${task.id}`,
                    })
                  }
                >
                  <Text
                    className={`calendar-page__task-title ${
                      task.done ? 'is-done' : ''
                    }`}
                  >
                    {task.title}
                  </Text>
                  <Text className='calendar-page__task-meta'>
                    {taskPriorityLabel(task.priority)}
                    {task.category ? ` · ${task.category}` : ''}
                  </Text>
                </View>
              </View>
            ))}
          </>
        )}
      </View>

      <AppDock />
    </View>
  )
}
