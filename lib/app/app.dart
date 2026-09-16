import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import 'router.dart';

/// 根应用：系统栏样式 + 自定义主题 + 路由。
class YuetuApp extends ConsumerWidget {
  const YuetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 读取路由并配置系统状态栏/导航栏外观
    final GoRouter router = ref.watch(routerProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 2. 以 MaterialApp.router 为宿主，视觉完全交给自建主题与组件
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
