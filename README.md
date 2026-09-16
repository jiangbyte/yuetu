# 月兔（yuetu）

记账 · 任务 · 笔记 · 专注 · 打卡 — Android / Linux UI 壳（内存假数据，不落库）。

## 目录

```
lib/
  app/                 # 根应用与路由
  core/                # Token、自建组件
  features/
    shell/             # 可配置底栏
    tasks/ calendar/ ledger/ notes/ focus/ checkin/ mine/
```

## 运行

```bash
flutter pub get
flutter run -d linux
# Android：连接设备后 flutter run
```

## 说明

- 底栏可在「更多 → 底栏设置」中勾选与排序
- 笔记支持富文本与语音转写（Linux 上语音可能不可用）
- 本阶段无数据库，重启后数据重置
