# 月兔（yuetu）

![CI](https://github.com/jiangbyte/yuetu/actions/workflows/ci.yml/badge.svg)
![Release](https://github.com/jiangbyte/yuetu/actions/workflows/release.yml/badge.svg)
![Taro](https://img.shields.io/badge/Taro-4.2-blue)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite&logoColor=white)
![Capacitor](https://img.shields.io/badge/Capacitor-Android-119EFF?logo=capacitor&logoColor=white)

**月兔** 是一款本地优先的个人账本与事项 Android App：流水记账、日历总览、任务与笔记；数据落在本机 SQLite，不上传云端。  
仓库：[jiangbyte/yuetu](https://github.com/jiangbyte/yuetu)

> 坐标：`io.github.jiangbyte.yuetu` · 作者：[Charlie Zhang](https://github.com/jiangbyte) · 邮箱：`jiangbytebiz@163.com`

## 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [工程结构](#工程结构)
- [快速开始](#快速开始)
- [Android APK](#android-apk)
- [作者](#作者)

## 功能特性

| 模块 | 说明 |
| --- | --- |
| 流水 | 月度汇总、收支筛选、分类标签、搜索与无限滚动；可记支付方式 |
| 日历 | 月历圆点标记流水 / 任务；查看当日明细 |
| 事项 | 任务与笔记合一；日期、优先级、分类筛选与搜索 |
| 报表 | ECharts 驱动的收支分析（从流水进入） |
| 我的 | 分类管理、数据导入导出 / 清空、关于 |
| 底部 Dock | 流水 · 日历 · ⊕ · 事项 · 我的；中间扇形快捷记一笔 / 新任务 / 写笔记 |

**做齐：** 本地 SQLite、自定义顶栏与返回、Capacitor 打 Android release APK。  
**刻意不做：** 云同步、账号体系、多账本协作。

## 技术栈

| 层级 | 技术 |
| --- | --- |
| 框架 | Taro 4 · React · TypeScript |
| 数据 | SQLite（H5：`sql.js` wasm + IndexedDB；RN：`@op-engineering/op-sqlite`） |
| 图表 | Apache ECharts（H5：`echarts-for-react`；RN：`@wuba/react-native-echarts`） |
| 打包 | Capacitor（`android/`）包装 H5 产物；包管理 **pnpm** |

## 工程结构

```text
yuetu/
├── src/
│   ├── components/     # AppDock、AppPageHeader、卡片等
│   ├── domain/         # 类型与领域常量
│   ├── db/             # sql.js 接入与 migrations
│   ├── repositories/   # 流水 / 任务 / 笔记 / 分类仓储
│   ├── pages/          # 流水、日历、事项、我的及二级页
│   └── styles/         # 设计 token
├── android/            # Capacitor Android 工程
├── config/             # Taro 构建配置
├── capacitor.config.ts
└── package.json
```

## 快速开始

### 环境要求

- Node.js 18+
- pnpm 8+
- Android 构建另需 **JDK 21**、Android SDK（可用 Android Studio）

### 安装

```bash
git clone git@github.com:jiangbyte/yuetu.git
cd yuetu
pnpm install
# 若提示 ignored builds：
pnpm approve-builds --all && pnpm install
```

### 开发（H5）

```bash
pnpm exec taro build --type h5 --watch --port 10086
# 或
pnpm dev:h5
```

浏览器打开终端提示地址（默认 `http://localhost:10086`）。

### 构建 H5

```bash
pnpm build:h5
```

产物在 `dist/`（含 `static/sql-wasm-browser.wasm`）。

## Android APK

工程已接入 Capacitor，原生目录在 `android/`。

```bash
# 1. 构建 H5 并同步到 android
pnpm sync:android

# 2a. Android Studio 打开（推荐）
pnpm open:android

# 2b. 命令行打 release 包（需 JDK 21）
export JAVA_HOME=/path/to/jdk-21
pnpm build:android
```

Release APK 路径：

`android/app/build/outputs/apk/release/app-release.apk`

推送 `v*` tag 时，GitHub Actions 会自动构建 Android release APK 并发布 Release。说明见 `docs/release-notes/`。

### Android（React Native，可选）

按 [Taro RN](https://docs.taro.zone/docs/react-native) 关联原生工程后：

```bash
pnpm dev:rn
pnpm build:rn -- --platform android
```

## 作者

| 项 | 内容 |
| --- | --- |
| 作者 | Charlie Zhang（[jiangbyte](https://github.com/jiangbyte)） |
| 邮箱 | jiangbytebiz@163.com |
| 仓库 | [github.com/jiangbyte/yuetu](https://github.com/jiangbyte/yuetu) |
| AppId | `io.github.jiangbyte.yuetu` |
