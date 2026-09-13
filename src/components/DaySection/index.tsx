import { Text, View } from '@tarojs/components'
import type { PropsWithChildren } from 'react'
import { formatDayLabel } from '../../utils/date'
import { formatMoney } from '../../utils/money'
import './index.scss'

export function DaySection({
  date,
  income,
  expense,
  hideHead = false,
  children,
}: PropsWithChildren<{
  date: string
  income: number
  expense: number
  hideHead?: boolean
}>) {
  return (
    <View className='day-section'>
      {!hideHead && (
        <View className='day-section__head'>
          <Text className='day-section__date'>{formatDayLabel(date)}</Text>
          <Text className='day-section__sum'>
            支 {formatMoney(expense)} · 收 {formatMoney(income)}
          </Text>
        </View>
      )}
      <View className='day-section__body'>{children}</View>
    </View>
  )
}
