import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import 'router.dart';

/// 根应用。
class YuetuApp extends ConsumerWidget {
  const YuetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      color: AppColors.canvas,
      theme: buildAppTheme(),
      routerConfig: router,
      builder: (context, child) {
        return Material(
          color: AppColors.canvas,
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              decoration: TextDecoration.none,
              decorationColor: Color(0x00000000),
              backgroundColor: Color(0x00000000),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
