import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// 应用入口：初始化绑定并挂载根应用。
void main() {
  // 1. 确保 Flutter 引擎绑定完成（后续可在此做异步预热）
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 用 Riverpod 包裹根应用，便于注入路由与后续状态
  runApp(
    const ProviderScope(
      child: YuetuApp(),
    ),
  );
}
