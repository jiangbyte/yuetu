import { Text } from '@tarojs/components'
import { formatMoney, signedMoney } from '../../utils/money'
import './index.scss'

export function AmountText({
  value,
  type,
  signed = false,
  size = 'md',
}: {
  value: number
  type?: 'income' | 'expense'
  signed?: boolean
  size?: 'sm' | 'md' | 'lg'
}) {
  const tone =
    type === 'income' ? 'income' : type === 'expense' ? 'expense' : 'neutral'
  const text =
    signed && type ? signedMoney(type, value) : formatMoney(value)

  return (
    <Text className={`amount-text amount-text--${tone} amount-text--${size}`}>
      {text}
    </Text>
  )
}
