import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// 构建滴答风格主题，弱化 Material 默认视觉。
ThemeData buildAppTheme() {
  // 1. ColorScheme 绑定 Token，去掉易发黄的 surfaceTint
  final colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    outline: AppColors.stroke,
    surfaceTint: Colors.transparent,
  );

  // 2. 文字层级：明确无背景色，避免系统/引擎默认黄底
  const transparentBg = TextStyle(backgroundColor: Colors.transparent);
  final textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: AppTypography.display,
      fontWeight: AppTypography.bold,
      height: 1.2,
      color: AppColors.ink,
      backgroundColor: Colors.transparent,
    ),
    titleLarge: const TextStyle(
      fontSize: AppTypography.pageTitle,
      fontWeight: AppTypography.bold,
      height: 1.25,
      color: AppColors.ink,
      backgroundColor: Colors.transparent,
    ),
    bodyLarge: const TextStyle(
      fontSize: AppTypography.body,
      fontWeight: AppTypography.regular,
      height: 1.5,
      color: AppColors.ink,
      backgroundColor: Colors.transparent,
    ),
    bodyMedium: transparentBg.copyWith(
      fontSize: AppTypography.body,
      color: AppColors.ink,
    ),
    labelLarge: const TextStyle(
      fontSize: AppTypography.label,
      fontWeight: AppTypography.medium,
      height: 1.2,
      color: AppColors.onPrimary,
      backgroundColor: Colors.transparent,
    ),
  );

  // 3. 关闭 splash，输入框/选区不用黄高亮
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.canvas,
    canvasColor: AppColors.canvas,
    textTheme: textTheme,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    dividerColor: AppColors.stroke,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primarySoft,
      selectionHandleColor: AppColors.primary,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      fillColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
