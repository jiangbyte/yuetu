import { useState } from 'react'
import { Text, View } from '@tarojs/components'
import Taro from '@tarojs/taro'
import { AppButton } from '../../components/AppButton'
import { AppCard } from '../../components/AppCard'
import { AppPageHeader } from '../../components/AppPageHeader'
import { dataRepo } from '../../repositories/dataRepo'
import { downloadJsonFile } from '../../utils/download'
import './data.scss'

export default function MineDataPage() {
  const [exporting, setExporting] = useState(false)
  const [clearing, setClearing] = useState(false)

  const onExport = async () => {
    setExporting(true)
    try {
      // 1. 拉取本地全量业务数据
      // 2. 触发下载（H5）或写入剪贴板
      const bundle = await dataRepo.exportBundle()
      const day = new Date().toISOString().slice(0, 10)
      const mode = await downloadJsonFile(`yuetu-backup-${day}.json`, bundle)
      Taro.showToast({
        title: mode === 'download' ? '已开始下载' : '已复制到剪贴板',
        icon: 'success',
      })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '导出失败', icon: 'none' })
    } finally {
      setExporting(false)
    }
  }

  const onClear = async () => {
    const res = await Taro.showModal({
      title: '清空全部本地数据？',
      content: '流水、笔记、任务都会删除，且不可恢复。',
    })
    if (!res.confirm) return
    setClearing(true)
    try {
      await dataRepo.clearUserContent()
      Taro.showToast({ title: '已清空', icon: 'success' })
    } catch (e: any) {
      Taro.showToast({ title: e?.message || '清空失败', icon: 'none' })
    } finally {
      setClearing(false)
    }
  }

  return (
    <View className='mine-data has-page-header'>
      <AppPageHeader title='数据' showBack />
      <AppCard className='mine-data__card'>
        <Text className='mine-data__title'>导出数据</Text>
        <Text className='mine-data__desc'>
          将流水、笔记、任务、分类导出为 JSON 文件，便于本机备份。
        </Text>
        <AppButton loading={exporting} onClick={onExport}>
          导出数据
        </AppButton>
      </AppCard>

      <AppCard className='mine-data__card'>
        <Text className='mine-data__title'>清空数据</Text>
        <Text className='mine-data__desc'>
          数据保存在本机 SQLite，不会上传云端。清空后不可恢复。
        </Text>
        <AppButton variant='danger' loading={clearing} onClick={onClear}>
          清空数据
        </AppButton>
      </AppCard>
    </View>
  )
}
