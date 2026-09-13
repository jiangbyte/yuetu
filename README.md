# 月兔（yuetu）

![CI](https://github.com/jiangbyte/yuetu/actions/workflows/ci.yml/badge.svg)
![Taro](https://img.shields.io/badge/Taro-4.2-blue)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite&logoColor=white)
![Capacitor](https://img.shields.io/badge/Capacitor-Android-119EFF?logo=capacitor&logoColor=white)
![License](https://img.shields.io/badge/License-Apache_2.0-blue)

**月兔** 是一款本地优先的个人账本与事项 Android App：流水记账、日历总览、任务与笔记；数据落在本机 SQLite，不上传云端。  
仓库：[jiangbyte/yuetu](https://github.com/jiangbyte/yuetu)

> 坐标：`io.github.jiangbyte.yuetu` · 协议：[Apache License 2.0](LICENSE)

## 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [工程结构](#工程结构)
- [快速开始](#快速开始)
- [Android APK](#android-apk)
- [Q&A](#qa)
- [License](#license)

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
**当前不做：** 强制云同步、账号体系、多账本协作（云端若后续提供，会做成可选能力）。

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

推送 `v*` tag，或在 Actions 里对 **CI** 手动运行并勾选 publish，会自动构建 Android release APK 并发布 GitHub Release。说明见 `docs/release-notes/`。

### Android（React Native，可选）

按 [Taro RN](https://docs.taro.zone/docs/react-native) 关联原生工程后：

```bash
pnpm dev:rn
pnpm build:rn -- --platform android
```

## Q&A

### 开发动机是什么？

想做一个**先本地可用**的个人账本 + 事项工具：记流水、看日历、管任务与笔记，日常够用即可。首发不强制登录、不依赖云，避免「装完还要注册才能用」。顺手练完整条链路：Taro 多端工程、本地 SQLite、Capacitor 打 Android 包与 GitHub Release。

### 有哪些功能？当前不做哪些？

**有：**

- 流水（收支、分类、支付方式、搜索、分页）与报表
- 日历总览；事项（任务 / 笔记、优先级、到期日）
- 分类管理、数据导出 / 清空；自定义顶栏与底部 Dock

**当前版本不做：** 云同步、账号体系、多账本协作、社交分享。换机请自行导出备份。云端能力若后续推出，会作为**可选**能力单独说明，不会默默改成「必须上网才能用」。

### 为什么用 Taro（Web / 混合）而不用 Flutter？

两方面：

1. **环境现状**：开发机刚配好 Web 与 Android SDK，Flutter 工具链还没准备好，先用现成环境把 App 跑起来、打出 APK。
2. **端形态预留**：Taro 同一套 React + TypeScript 业务代码，之后若要出 **H5 网页** 或 **微信小程序**，迁移成本通常低于从 Flutter 另起一套。这里说的是「方便再出端」，**不等于**现在就要上云或把数据放到服务器。

当前 Android 包是 Capacitor 包装 H5 产物，属于务实的混合方案，不是否定原生或 Flutter，只是在现有条件下优先可交付与可扩展。

### 数据安全吗？会上传吗？

- **当前版本**：业务数据只写在本机 SQLite（H5 为 sql.js + IndexedDB），**没有**账号登录，也**没有**自动上传 / 远程同步逻辑。
- **之后**：不排除增加**可选**的云备份、多端同步等服务；上线时会明确开关与隐私说明。未开启前，行为仍以本地为准。
- **备份**：导出 / 清空在「我的 → 数据」；卸载或清应用数据会丢库，重要账目请自行备份。
- **可审计**：代码与构建公开；Release APK 由 Actions / 本地 `assembleRelease` 打出。分发签名在仓库内用于可复现构建，若要强隔离可自行换 keystore 重签。

### 和「原生 / RN 真机性能」比怎么样？

首发目标是功能闭环与本地可用，不是极致原生性能。列表分页、图表按需加载，日常记账体量足够。若后续要更贴系统体验，可走 Taro RN 路径或替换壳层，领域与仓储层已相对独立。

## License

本项目基于 [Apache License 2.0](LICENSE) 开源。完整条款见 [LICENSE](LICENSE)，版权声明见 [NOTICE](NOTICE)。
