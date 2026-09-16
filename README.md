# 月兔（yuetu）

Flutter 空白壳（Android / Linux）：自定义主题与基础组件，无第三方 UI 库。

## 目录

```
lib/
  app/           # 根应用与路由
  core/          # 主题 Token、自建组件、常量
  features/      # 按功能扩展（当前仅 home）
```

## 运行

```bash
flutter pub get
flutter run -d linux        # Linux
# Android：连接设备或启动模拟器后 flutter run
```

## 构建

```bash
flutter build apk
flutter build linux
```
