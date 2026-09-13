import { View } from '@tarojs/components'
import type { PropsWithChildren } from 'react'
import './index.scss'

export function AppCard({
  children,
  className = '',
}: PropsWithChildren<{ className?: string }>) {
  return <View className={`app-card ${className}`.trim()}>{children}</View>
}
