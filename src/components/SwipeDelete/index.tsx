import { useEffect, useRef, useState } from 'react'
import { Text, View } from '@tarojs/components'
import type { PropsWithChildren } from 'react'
import './index.scss'

/** 删除条宽度（CSS px，约等于设计稿 140） */
const ACTION_W = 72
const THRESHOLD = 36

/**
 * 左滑露出删除按钮；仅横向滑动时拦截，纵向仍交给页面滚动。
 */
export function SwipeDelete({
  open,
  onOpenChange,
  onDelete,
  className = '',
  children,
}: PropsWithChildren<{
  open: boolean
  onOpenChange: (open: boolean) => void
  onDelete: () => void
  className?: string
}>) {
  const startX = useRef(0)
  const startY = useRef(0)
  const base = useRef(0)
  const axis = useRef<'none' | 'x' | 'y'>('none')
  const moved = useRef(false)
  const [offset, setOffset] = useState(0)
  const [dragging, setDragging] = useState(false)

  useEffect(() => {
    if (!dragging) setOffset(open ? -ACTION_W : 0)
  }, [open, dragging])

  const shown = dragging ? offset : open ? -ACTION_W : 0

  const onTouchStart = (e: any) => {
    const t = e.changedTouches?.[0] || e.touches?.[0]
    if (!t) return
    // 1. 记录起点与当前展开基准
    startX.current = t.clientX
    startY.current = t.clientY
    base.current = open ? -ACTION_W : 0
    axis.current = 'none'
    moved.current = false
    setOffset(base.current)
  }

  const onTouchMove = (e: any) => {
    const t = e.changedTouches?.[0] || e.touches?.[0]
    if (!t) return
    const dx = t.clientX - startX.current
    const dy = t.clientY - startY.current

    // 2. 判定轴向，避免和列表纵向滚动冲突
    if (axis.current === 'none') {
      if (Math.abs(dx) < 6 && Math.abs(dy) < 6) return
      axis.current = Math.abs(dx) > Math.abs(dy) ? 'x' : 'y'
      if (axis.current === 'y') return
      setDragging(true)
    }
    if (axis.current !== 'x') return

    moved.current = true
    // 3. 限制在 [−ACTION_W, 0]
    const next = Math.min(0, Math.max(-ACTION_W, base.current + dx))
    setOffset(next)
  }

  const onTouchEnd = () => {
    if (axis.current !== 'x') {
      setDragging(false)
      return
    }
    // 4. 超过阈值则展开，否则收回
    const shouldOpen = offset <= -THRESHOLD
    setDragging(false)
    onOpenChange(shouldOpen)
    setOffset(shouldOpen ? -ACTION_W : 0)
    axis.current = 'none'
  }

  return (
    <View className={`swipe-delete ${className}`.trim()}>
      <View className='swipe-delete__actions'>
        <View
          className='swipe-delete__delete'
          onClick={(e) => {
            e.stopPropagation?.()
            onDelete()
          }}
        >
          <Text className='swipe-delete__delete-text'>删除</Text>
        </View>
      </View>
      <View
        className='swipe-delete__content'
        style={{
          transform: `translateX(${shown}px)`,
          transition: dragging ? 'none' : 'transform 0.2s ease',
        }}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        onTouchCancel={onTouchEnd}
        onClick={(e) => {
          if (moved.current) {
            e.stopPropagation?.()
            moved.current = false
            return
          }
          if (open) {
            e.stopPropagation?.()
            onOpenChange(false)
          }
        }}
      >
        {children}
      </View>
    </View>
  )
}
