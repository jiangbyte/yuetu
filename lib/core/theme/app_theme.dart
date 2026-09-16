import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// 构建弱化 Material 默认视觉的主题，颜色与文字绑定到 Design Token。
ThemeData buildAppTheme() {
  // 1. 基于 Token 组装 ColorScheme，避免默认紫系 Material 色
  final colorScheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.stroke,
  );

  // 2. 绑定文字样式到 Token，页面通过 AppText 再二次约束
  final textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: AppTypography.display,
      fontWeight: AppTypography.bold,
      height: 1.15,
      letterSpacing: -0.8,
      color: AppColors.ink,
    ),
    titleLarge: const TextStyle(
      fontSize: AppTypography.title,
      fontWeight: AppTypography.medium,
      height: 1.3,
      color: AppColors.ink,
    ),
    bodyLarge: const TextStyle(
      fontSize: AppTypography.body,
      fontWeight: AppTypography.regular,
      height: 1.5,
      color: AppColors.inkMuted,
    ),
    labelLarge: const TextStyle(
      fontSize: AppTypography.label,
      fontWeight: AppTypography.medium,
      height: 1.2,
      color: AppColors.onAccent,
    ),
  );

  // 3. 关闭默认 splash/高亮，交给自建组件控制交互反馈
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.canvas,
    textTheme: textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    dividerColor: AppColors.stroke,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
