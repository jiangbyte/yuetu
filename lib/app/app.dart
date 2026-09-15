import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

final routerProvider = Provider<GoRouter>((ref) => createRouter());

/// 根应用：主题 + 路由。
class YuetuApp extends ConsumerWidget {
  const YuetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.sheet,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: '月兔',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
