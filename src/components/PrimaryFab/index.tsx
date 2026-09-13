import { Text, View } from '@tarojs/components'
import { Plus } from 'lucide-react'
import { AppIcon } from '../AppIcon'
import './index.scss'

/** 页面右下角悬浮添加按钮 */
export function PrimaryFab({
  label,
  onClick,
}: {
  label?: string
  onClick: () => void
}) {
  const labeled = !!label
  return (
    <View
      className={`primary-fab ${labeled ? 'primary-fab--labeled' : ''}`.trim()}
      onClick={onClick}
    >
      <AppIcon
        icon={Plus}
        size={labeled ? 18 : 28}
        color={labeled ? '#ffffff' : '#1a1a1a'}
      />
      {labeled && <Text className='primary-fab__label'>{label}</Text>}
    </View>
  )
}
