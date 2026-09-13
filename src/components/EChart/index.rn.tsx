import { useEffect, useRef } from 'react'
import { View } from '@tarojs/components'
import { SVGRenderer, SkiaChart } from '@wuba/react-native-echarts'
import * as echarts from 'echarts/core'
import { PieChart, LineChart, BarChart } from 'echarts/charts'
import {
  GridComponent,
  LegendComponent,
  TooltipComponent,
} from 'echarts/components'
import type { EChartsOption } from 'echarts'
import './index.scss'

echarts.use([
  SVGRenderer,
  PieChart,
  LineChart,
  BarChart,
  GridComponent,
  LegendComponent,
  TooltipComponent,
])

/** RN：用 @wuba/react-native-echarts 渲染专业图表 */
export function EChart({
  option,
  height = 280,
}: {
  option: EChartsOption
  height?: number
}) {
  const ref = useRef<any>(null)

  useEffect(() => {
    let chart: echarts.ECharts | undefined
    if (ref.current) {
      chart = echarts.init(ref.current, 'light', {
        renderer: 'svg',
        width: 320,
        height,
      })
      chart.setOption(option)
    }
    return () => chart?.dispose()
  }, [option, height])

  return (
    <View className='e-chart' style={{ height: `${height}px` }}>
      <SkiaChart ref={ref} />
    </View>
  )
}
