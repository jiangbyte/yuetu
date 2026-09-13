import { useCallback, useMemo, useState } from 'react'
import { Text, View } from '@tarojs/components'
import Taro, { useDidShow } from '@tarojs/taro'
import type { EChartsOption } from 'echarts'
import { AppCard } from '../../components/AppCard'
import { AppPageHeader } from '../../components/AppPageHeader'
import { EChart } from '../../components/EChart'
import { AmountText } from '../../components/AmountText'
import type { CategoryAgg, DayTrend, MonthSummary } from '../../domain/types'
import { transactionRepo } from '../../repositories/transactionRepo'
import {
  currentYearMonth,
  formatYearMonth,
  monthRange,
  shiftYearMonth,
} from '../../utils/date'
import { formatMoney } from '../../utils/money'
import './index.scss'

export default function ReportsPage() {
  const [ym, setYm] = useState(currentYearMonth())
  const [summary, setSummary] = useState<MonthSummary>({
    income: 0,
    expense: 0,
    balance: 0,
  })
  const [categories, setCategories] = useState<CategoryAgg[]>([])
  const [trend, setTrend] = useState<DayTrend[]>([])
  const [loading, setLoading] = useState(true)

  const load = useCallback(async () => {
    setLoading(true)
    try {
      const [sum, cats, days] = await Promise.all([
        transactionRepo.monthSummary(ym),
        transactionRepo.categoryAgg(ym, 'expense'),
        transactionRepo.dayTrend(ym),
      ])
      setSummary(sum)
      setCategories(cats)
      setTrend(days)
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '加载失败', icon: 'none' })
    } finally {
      setLoading(false)
    }
  }, [ym])

  useDidShow(() => {
    load()
  })

  const pieOption = useMemo<EChartsOption>(() => {
    return {
      color: ['#1a1a1a', '#e07070', '#8c8c8c', '#5aaa9a', '#b0b0b0', '#666666', '#d0d0d0'],
      tooltip: { trigger: 'item' },
      series: [
        {
          type: 'pie',
          radius: ['48%', '72%'],
          avoidLabelOverlap: true,
          label: { formatter: '{b}\n{d}%' },
          data: categories.map((c) => ({ name: c.category, value: c.total })),
        },
      ],
    }
  }, [categories])

  const lineOption = useMemo<EChartsOption>(() => {
    return {
      color: ['#5aaa9a', '#e07070'],
      tooltip: {
        trigger: 'axis',
        backgroundColor: '#fff',
        borderColor: 'rgba(26,26,26,0.08)',
        borderWidth: 1,
        textStyle: { color: '#1a1a1a', fontSize: 12 },
        extraCssText: 'box-shadow: 0 4px 14px rgba(26,26,26,0.08); border-radius: 8px;',
      },
      // 图例固定顶部，避免压住 X 轴刻度
      legend: {
        top: 4,
        left: 'center',
        icon: 'circle',
        itemWidth: 8,
        itemHeight: 8,
        itemGap: 18,
        data: ['收入', '支出'],
        textStyle: { color: '#9a9a9a', fontSize: 11 },
      },
      grid: {
        left: 12,
        right: 12,
        top: 40,
        bottom: 8,
        containLabel: true,
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: trend.map((t) => t.day.slice(8)),
        axisTick: { show: false },
        axisLine: { lineStyle: { color: 'rgba(26,26,26,0.08)' } },
        axisLabel: { color: '#9a9a9a', fontSize: 11, margin: 10 },
      },
      yAxis: {
        type: 'value',
        splitNumber: 4,
        axisLine: { show: false },
        axisTick: { show: false },
        axisLabel: { color: '#9a9a9a', fontSize: 11 },
        splitLine: { lineStyle: { color: 'rgba(26,26,26,0.06)', type: 'dashed' } },
      },
      series: [
        {
          name: '收入',
          type: 'line',
          smooth: true,
          symbol: 'circle',
          symbolSize: 6,
          showSymbol: false,
          data: trend.map((t) => t.income),
        },
        {
          name: '支出',
          type: 'line',
          smooth: true,
          symbol: 'circle',
          symbolSize: 6,
          showSymbol: false,
          data: trend.map((t) => t.expense),
        },
      ],
    }
  }, [trend])

  const barOption = useMemo<EChartsOption>(() => {
    const sorted = [...categories].reverse()
    return {
      color: ['#1a1a1a'],
      tooltip: { trigger: 'axis' },
      grid: { left: 72, right: 24, top: 16, bottom: 24 },
      xAxis: { type: 'value' },
      yAxis: {
        type: 'category',
        data: sorted.map((c) => c.category),
      },
      series: [
        {
          type: 'bar',
          data: sorted.map((c) => c.total),
          barWidth: 14,
          itemStyle: { borderRadius: [0, 8, 8, 0] },
        },
      ],
    }
  }, [categories])

  const dayCount = (() => {
    const { end } = monthRange(ym)
    return Number(end.slice(8))
  })()
  const dailyAvg = summary.expense / Math.max(dayCount, 1)
  const top = categories[0]

  return (
    <View className='reports-page has-page-header'>
      <AppPageHeader title='报表' showBack />
      <View className='reports-page__month'>
        <Text className='reports-page__arrow' onClick={() => setYm(shiftYearMonth(ym, -1))}>
          ‹
        </Text>
        <Text className='reports-page__ym'>{formatYearMonth(ym)}</Text>
        <Text className='reports-page__arrow' onClick={() => setYm(shiftYearMonth(ym, 1))}>
          ›
        </Text>
      </View>

      <AppCard className='reports-page__summary'>
        <View className='reports-page__summary-row'>
          <View>
            <Text className='reports-page__label'>总支出</Text>
            <AmountText value={summary.expense} type='expense' size='md' />
          </View>
          <View>
            <Text className='reports-page__label'>日均</Text>
            <AmountText value={dailyAvg} size='md' />
          </View>
        </View>
        <Text className='reports-page__top'>
          {top
            ? `本月最多花在「${top.category}」：¥${formatMoney(top.total)}`
            : '本月暂无支出分类数据'}
        </Text>
      </AppCard>

      {loading && <Text className='reports-page__empty'>加载中...</Text>}

      {!loading && (
        <>
          <AppCard className='reports-page__card'>
            <Text className='reports-page__card-title'>分类支出</Text>
            {categories.length === 0 ? (
              <Text className='reports-page__hint'>暂无数据</Text>
            ) : (
              <EChart option={pieOption} height={260} />
            )}
          </AppCard>

          <AppCard className='reports-page__card'>
            <Text className='reports-page__card-title'>收支趋势</Text>
            {trend.length === 0 ? (
              <Text className='reports-page__hint'>暂无数据</Text>
            ) : (
              <EChart option={lineOption} height={280} />
            )}
          </AppCard>

          <AppCard className='reports-page__card'>
            <Text className='reports-page__card-title'>分类占比</Text>
            {categories.length === 0 ? (
              <Text className='reports-page__hint'>暂无数据</Text>
            ) : (
              <EChart option={barOption} height={Math.max(220, categories.length * 36)} />
            )}
          </AppCard>
        </>
      )}
    </View>
  )
}
