# 月兔（yuetu）

![CI](https://github.com/jiangbyte/yuetu/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Drift-003B57?logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/License-Apache_2.0-blue)

**月兔** 是一款本地优先的个人账本与事项 App：流水记账、日历总览、任务与笔记；数据落在本机 SQLite，不上传云端。  
仓库：[jiangbyte/yuetu](https://github.com/jiangbyte/yuetu)

> 坐标：`io.github.jiangbyte.yuetu` · 协议：[Apache License 2.0](LICENSE)

## 功能特性

| 模块 | 说明 |
| --- | --- |
| 流水 | 月度汇总、日条筛选、分类标签、搜索与分页；可记支付方式 |
| 日历 | 月历圆点标记流水 / 任务；查看当日明细 |
| 事项 | 任务与笔记合一；日期、优先级、分类筛选与搜索 |
| 报表 | fl_chart 驱动的支出构成与每日趋势 |
| 我的 | 分类管理、数据导出 / 清空、关于 |
| 底部 Dock | 流水 · 日历 · ⊕ · 事项 · 我的；中间扇形快捷记一笔 / 新任务 / 写笔记 |

**做齐：** 本地 SQLite（Drift）、自定义顶栏与 Dock、Android / iOS。  
**当前不做：** 强制云同步、账号体系、多账本协作。

## 技术栈

| 层级 | 技术 |
| --- | --- |
| 框架 | Flutter · Dart |
| 状态 | Riverpod |
| 路由 | go_router（Shell + 二级页） |
| 数据 | Drift（SQLite） |
| 图表 | fl_chart |
| 架构 | feature-first Clean Architecture |

## 工程结构

```text
yuetu/
├── lib/
│   ├── app/                 # 启动、路由、根 Widget
│   ├── core/                # 主题、常量、工具、跨 feature 组件
│   ├── data/                # Drift 与 repositories
│   ├── domain/              # 领域模型
│   └── features/            # ledger / calendar / tasks / reports / …
├── android/  ios/
├── test/
└── pubspec.yaml
```

## 快速开始

### 环境要求

- Flutter 3.24+（推荐稳定版）
- Android：JDK 17+、Android SDK
- iOS：Xcode（仅 macOS）

### 安装与运行

```bash
git clone git@github.com:jiangbyte/yuetu.git
cd yuetu
flutter pub get
flutter run
```

指定平台：

```bash
flutter run -d android
flutter run -d ios
```

### 代码生成（修改 Drift 表后）

```bash
dart run build_runner build
```

### 质量检查

```bash
flutter analyze
flutter test
```

## 构建发布

### Android APK

```bash
flutter build apk --release
```

产物：`build/app/outputs/flutter-apk/app-release.apk`

默认 release 使用 debug 签名，便于本地验证；正式上架请配置自己的 `signingConfigs`。

### iOS

```bash
flutter build ipa --release
```

需在 Xcode 中配置 Team / Bundle ID（默认 `io.github.jiangbyte.yuetu`）。

## Q&A

**数据存在哪里？**  
应用文档目录下的 `yuetu.db`（Drift / SQLite），不上传云端。

**能否导入旧 Capacitor 版本数据？**  
当前不提供迁移；新安装从空库 + 默认分类开始。可用「数据管理」导出 JSON 备份。

## License

Apache License 2.0 · 见 [LICENSE](LICENSE) 与 [NOTICE](NOTICE)
