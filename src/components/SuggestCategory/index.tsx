import { useEffect, useMemo, useState } from 'react'
import { Input, Text, View } from '@tarojs/components'
import type { CategoryKind } from '../../domain/types'
import { categoryRepo } from '../../repositories/categoryRepo'
import './index.scss'

/** 可输入分类，下方展示历史选项供点选 */
export function SuggestCategory({
  kind,
  value,
  onChange,
  placeholder = '输入或选择分类',
}: {
  kind: CategoryKind
  value: string
  onChange: (v: string) => void
  placeholder?: string
}) {
  const [options, setOptions] = useState<string[]>([])

  useEffect(() => {
    ;(async () => {
      try {
        const rows = await categoryRepo.listByType(kind)
        setOptions(rows.map((r) => r.name))
      } catch {
        setOptions([])
      }
    })()
  }, [kind])

  const suggestions = useMemo(() => {
    const q = value.trim()
    if (!q) return options.slice(0, 8)
    return options.filter((n) => n.includes(q)).slice(0, 8)
  }, [options, value])

  return (
    <View className='suggest-category'>
      <Input
        className='suggest-category__input'
        placeholder={placeholder}
        value={value}
        maxlength={12}
        onInput={(e) => onChange(e.detail.value)}
      />
      {suggestions.length > 0 && (
        <View className='suggest-category__chips'>
          {suggestions.map((name) => (
            <Text
              key={name}
              className={`suggest-category__chip ${
                value === name ? 'is-active' : ''
              }`}
              onClick={() => onChange(name)}
            >
              {name}
            </Text>
          ))}
        </View>
      )}
    </View>
  )
}
