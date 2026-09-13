import { Text, View } from '@tarojs/components'
import './index.scss'

const FALLBACK = '#8c8c8c'

export function CategoryIcon({
  category,
  color,
}: {
  category: string
  color?: string
}) {
  const tint = color || FALLBACK
  const label = category.slice(0, 1)

  return (
    <View className='category-icon' style={{ background: tint }}>
      <Text className='category-icon__text'>{label}</Text>
    </View>
  )
}
