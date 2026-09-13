import type { LucideIcon } from 'lucide-react'

/** 统一离线图标：lucide 内联 SVG，打包进产物，无 CDN */
export function AppIcon({
  icon: Icon,
  size = 20,
  color = 'currentColor',
  strokeWidth = 1.75,
  className,
}: {
  icon: LucideIcon
  size?: number
  color?: string
  strokeWidth?: number
  className?: string
}) {
  return (
    <Icon
      className={className}
      size={size}
      color={color}
      strokeWidth={strokeWidth}
      absoluteStrokeWidth
      aria-hidden
    />
  )
}
