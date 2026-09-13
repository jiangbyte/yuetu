import ReactECharts from 'echarts-for-react'
import type { EChartsOption } from 'echarts'
import { View } from '@tarojs/components'
import './index.scss'

/** H5：用 echarts-for-react 渲染专业图表 */
export function EChart({
  option,
  height = 280,
}: {
  option: EChartsOption
  height?: number
}) {
  return (
    <View className='e-chart' style={{ height: `${height}px` }}>
      <ReactECharts
        option={option}
        style={{ height: '100%', width: '100%' }}
        opts={{ renderer: 'canvas' }}
        notMerge
        lazyUpdate
      />
    </View>
  )
}
