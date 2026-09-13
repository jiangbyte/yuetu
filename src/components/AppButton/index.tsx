import { Text, View } from '@tarojs/components'
import { LoaderCircle } from 'lucide-react'
import { AppIcon } from '../AppIcon'
import './index.scss'

type AppButtonVariant = 'primary' | 'danger' | 'secondary' | 'ghost'
type AppButtonSize = 'md' | 'mini'

/**
 * 统一操作按钮：自绘布局保证文字垂直居中，避免 Taro/WeUI Button 默认样式偏移。
 */
export function AppButton({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  block = true,
  className = '',
  onClick,
}: {
  children: string
  variant?: AppButtonVariant
  size?: AppButtonSize
  loading?: boolean
  disabled?: boolean
  block?: boolean
  className?: string
  onClick?: () => void
}) {
  const idle = disabled || loading

  return (
    <View
      className={[
        'app-button',
        `app-button--${variant}`,
        `app-button--${size}`,
        block ? 'app-button--block' : '',
        idle ? 'is-disabled' : '',
        className,
      ]
        .filter(Boolean)
        .join(' ')}
      onClick={() => {
        if (idle) return
        onClick?.()
      }}
    >
      {loading && (
        <View className='app-button__spin'>
          <AppIcon
            icon={LoaderCircle}
            size={14}
            color='currentColor'
            className='app-button__spinner'
          />
        </View>
      )}
      <Text className='app-button__text'>{children}</Text>
    </View>
  )
}
